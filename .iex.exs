IO.puts("--------------------------- RAGGED DATA ---------------------------")
IO.puts("------------------------------ CROW -------------------------------")

import_file_if_available("~/.iex.exs")

alias CrowData.Ctx.Event
alias CrowData.Ctx.Account.{User, Folder, FeedLog}

alias CrowData.Repo
alias CrowData.Repo, as: R

alias Porcelain.Result
alias Porcelain, as: Pcl

import_if_available(Ecto.Query)

