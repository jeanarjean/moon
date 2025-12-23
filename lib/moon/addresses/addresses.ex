defmodule Moon.Addresses do
  @moduledoc """
  The Addresses context.
  """

  import Ecto.Query, warn: false
  alias Moon.Repo

  alias Moon.Addresses.Schema.Address
  alias Moon.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any address changes.

  The broadcasted messages match the pattern:

    * {:created, %Address{}}
    * {:updated, %Address{}}
    * {:deleted, %Address{}}

  """
  def subscribe_addresses(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Moon.PubSub, "user:#{key}:addresses")
  end

  defp broadcast_address(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Moon.PubSub, "user:#{key}:addresses", message)
  end

  @doc """
  Returns the list of addresses.

  ## Examples

      iex> list_addresses(scope)
      [%Address{}, ...]

  """
  def list_addresses(%Scope{} = scope) do
    Repo.all_by(Address, user_id: scope.user.id)
  end

  @doc """
  Search addresses by name, street address, or city.
  Returns addresses matching the query, ordered by relevance.
  """
  def search_addresses(query) when is_binary(query) and query != "" do
    search_term = "%#{query}%"

    Address
    |> where(
      [a],
      ilike(a.name, ^search_term) or
        ilike(a.street_address, ^search_term) or
        ilike(a.city, ^search_term)
    )
    |> order_by([a], asc: a.name)
    |> limit(20)
    |> Repo.all()
  end

  @doc """
  Gets a single address.

  Raises `Ecto.NoResultsError` if the Address does not exist.

  ## Examples

      iex> get_address!(scope, 123)
      %Address{}

      iex> get_address!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_address!(%Scope{} = scope, id) do
    Repo.get_by!(Address, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a address.

  ## Examples

      iex> create_address(scope, %{field: value})
      {:ok, %Address{}}

      iex> create_address(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_address(%Scope{} = scope, attrs) do
    with {:ok, address = %Address{}} <-
           %Address{}
           |> Address.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_address(scope, {:created, address})
      {:ok, address}
    end
  end

  @doc """
  Updates a address.

  ## Examples

      iex> update_address(scope, address, %{field: new_value})
      {:ok, %Address{}}

      iex> update_address(scope, address, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_address(%Scope{} = scope, %Address{} = address, attrs) do
    true = address.user_id == scope.user.id

    with {:ok, address = %Address{}} <-
           address
           |> Address.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_address(scope, {:updated, address})
      {:ok, address}
    end
  end

  @doc """
  Deletes a address.

  ## Examples

      iex> delete_address(scope, address)
      {:ok, %Address{}}

      iex> delete_address(scope, address)
      {:error, %Ecto.Changeset{}}

  """
  def delete_address(%Scope{} = scope, %Address{} = address) do
    true = address.user_id == scope.user.id

    with {:ok, address = %Address{}} <-
           Repo.delete(address) do
      broadcast_address(scope, {:deleted, address})
      {:ok, address}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking address changes.

  ## Examples

      iex> change_address(scope, address)
      %Ecto.Changeset{data: %Address{}}

  """
  def change_address(%Scope{} = scope, %Address{} = address, attrs \\ %{}) do
    true = address.user_id == scope.user.id

    Address.changeset(address, attrs, scope)
  end
end
