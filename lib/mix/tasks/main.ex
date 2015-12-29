defmodule Mix.Tasks.Main do
  use Mix.Task

  def run(args) do
    Mix.Task.run "app.start"
    Mix.Project.get.project[:escript][:main_module].main(args) 
  end
end

