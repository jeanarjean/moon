defmodule Moon.AddressesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Moon.Addresses` context.
  """

  @doc """
  Generate a address.
  """
  def address_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "Port of Montreal",
        street_address: "2100 Pierre-Dupuy Ave",
        city: "Montreal",
        province: "QC",
        postal_code: "H3C 3R5",
        country: "Canada",
        lat: 45.5017,
        lng: -73.5673,
        address_type: "port",
        notes: "Main container terminal"
      })

    {:ok, address} = Moon.Addresses.create_address(scope, attrs)
    address
  end
end
