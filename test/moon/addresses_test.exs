defmodule Moon.AddressesTest do
  use Moon.DataCase

  alias Moon.Addresses

  describe "addresses" do
    alias Moon.Addresses.Schema.Address

    import Moon.AccountsFixtures, only: [user_scope_fixture: 0]
    import Moon.AddressesFixtures

    @invalid_attrs %{
      name: nil,
      street_address: nil,
      city: nil,
      province: nil,
      postal_code: nil,
      country: nil,
      lat: nil,
      lng: nil,
      address_type: nil,
      notes: nil
    }

    test "list_addresses/1 returns all scoped addresses" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      address = address_fixture(scope)
      other_address = address_fixture(other_scope)
      assert Addresses.list_addresses(scope) == [address]
      assert Addresses.list_addresses(other_scope) == [other_address]
    end

    test "get_address!/2 returns the address with given id" do
      scope = user_scope_fixture()
      address = address_fixture(scope)
      other_scope = user_scope_fixture()
      assert Addresses.get_address!(scope, address.id) == address
      assert_raise Ecto.NoResultsError, fn -> Addresses.get_address!(other_scope, address.id) end
    end

    test "create_address/2 with valid data creates a address" do
      valid_attrs = %{
        name: "Port of Montreal",
        street_address: "2100 Pierre-Dupuy Ave",
        city: "Montreal",
        province: "QC",
        postal_code: "H3C 3R5",
        country: "Canada",
        lat: Decimal.new("45.5017"),
        lng: Decimal.new("-73.5673"),
        address_type: "port",
        notes: "Main container terminal"
      }

      scope = user_scope_fixture()

      assert {:ok, %Address{} = address} = Addresses.create_address(scope, valid_attrs)
      assert address.name == "Port of Montreal"
      assert address.street_address == "2100 Pierre-Dupuy Ave"
      assert address.city == "Montreal"
      assert address.province == "QC"
      assert address.postal_code == "H3C 3R5"
      assert address.country == "Canada"
      assert address.lat == Decimal.new("45.5017")
      assert address.lng == Decimal.new("-73.5673")
      assert address.address_type == "port"
      assert address.notes == "Main container terminal"
      assert address.user_id == scope.user.id
    end

    test "create_address/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Addresses.create_address(scope, @invalid_attrs)
    end

    test "update_address/3 with valid data updates the address" do
      scope = user_scope_fixture()
      address = address_fixture(scope)

      update_attrs = %{
        name: "some updated name",
        street_address: "2100 Pierre-Dupuy Ave",
        city: "Montreal",
        province: "QC",
        postal_code: "H3C 3R5",
        country: "Canada",
        lat: Decimal.new("45.5017"),
        lng: Decimal.new("-73.5673"),
        address_type: "port",
        notes: "Main container terminal"
      }

      assert {:ok, %Address{} = address} = Addresses.update_address(scope, address, update_attrs)
      assert address.name == "some updated name"
      assert address.street_address == "2100 Pierre-Dupuy Ave"
      assert address.city == "Montreal"
      assert address.province == "QC"
      assert address.postal_code == "H3C 3R5"
      assert address.country == "Canada"
      assert address.lat == Decimal.new("45.5017")
      assert address.lng == Decimal.new("-73.5673")
      assert address.address_type == "port"
      assert address.notes == "Main container terminal"
    end

    test "update_address/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      address = address_fixture(scope)

      assert_raise MatchError, fn ->
        Addresses.update_address(other_scope, address, %{})
      end
    end

    test "update_address/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      address = address_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Addresses.update_address(scope, address, @invalid_attrs)

      assert address == Addresses.get_address!(scope, address.id)
    end

    test "delete_address/2 deletes the address" do
      scope = user_scope_fixture()
      address = address_fixture(scope)
      assert {:ok, %Address{}} = Addresses.delete_address(scope, address)
      assert_raise Ecto.NoResultsError, fn -> Addresses.get_address!(scope, address.id) end
    end

    test "delete_address/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      address = address_fixture(scope)
      assert_raise MatchError, fn -> Addresses.delete_address(other_scope, address) end
    end

    test "change_address/2 returns a address changeset" do
      scope = user_scope_fixture()
      address = address_fixture(scope)
      assert %Ecto.Changeset{} = Addresses.change_address(scope, address)
    end
  end
end
