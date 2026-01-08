defmodule ProgressTree.Repo do
  use Ecto.Repo,
    otp_app: :progress_tree,
    adapter: Ecto.Adapters.Postgres
end
