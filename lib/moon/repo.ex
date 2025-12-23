defmodule Moon.Repo do
  use Ecto.Repo,
    otp_app: :moon,
    adapter: Ecto.Adapters.Postgres
end
