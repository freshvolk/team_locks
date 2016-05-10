ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Caniuse.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Caniuse.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Caniuse.Repo)

