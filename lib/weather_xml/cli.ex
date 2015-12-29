defmodule WeatherXML.CLI do
  require Logger

  require Record
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText,    Record.extract(:xmlText,    from_lib: "xmerl/include/xmerl.hrl")

  def fields do
    ~w/ location station_id latitude longitude observation_time weather temp_f temp_c relative_humidity wind_string wind_dir wind_degrees wind_mph wind_kt pressure_mb pressure_in dewpoint_f dewpoint_c windchill_f windchill_c visibility_mi
     /
  end

  def main(args) do
    args
      |> Enum.map(&airport_to_url/1)
      |> Enum.each(&process_url/1)
  end

  def airport_to_url(airport) do
    "http://w1.weather.gov/xml/current_obs/K#{airport |> String.upcase}.xml"
  end

  def process_url(url) do
    url
      |> get_xml
      |> scan_xml
      |> parse(fields)
      |> print
  end

  def get_xml(url) do
    {:ok, %{body: body}} = HTTPoison.get(url)
    Logger.debug body
    body
  end

  def scan_xml(xml) when is_binary(xml) do
    xml
      |> String.to_char_list
      |> scan_xml
  end

  def scan_xml(xml) do
    { xml, _rest } = xml
      |> :xmerl_scan.string
    xml
  end

  # http://elixirsips.com/episodes/028_parsing_xml.html
  # http://rustamagasanov.com/blog/2015/10/19/parse-xml-with-elixir-and-xmerl-example/
  def parse(xml, fields) do
    fields
      |> Enum.map(fn key ->
        [element] = :xmerl_xpath.string('/current_observation/#{key}', xml)
        [text]    = xmlElement(element, :content)
        value     = xmlText(text, :value)
        key = key
          |> String.split("_")
          |> Enum.map_join(" ", &String.capitalize/1)
        Logger.debug "#{key} #{value}"
        {key, value}
      end)
  end

  def print(data) do
    data
      |> Enum.each(fn {k, v} -> IO.puts "#{k}: #{v}" end)
    IO.puts ""
  end
end

