defmodule Hasty.Repo do
  use Ecto.Repo,
    otp_app: :hasty,
    adapter: Ecto.Adapters.Postgres
end
