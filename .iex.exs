IO.puts("------------------------------ CROW -------------------------------")

import_file_if_available("~/.iex.exs")

alias CrowData.Ctx.{ObanJob, Result}

alias CrowData.Repo
alias CrowData.Repo, as: R

alias Porcelain, as: Pcl

import_if_available(Ecto.Query)

