defmodule MoonWeb.AddressLiveTest do
  use MoonWeb.ConnCase

  import Phoenix.LiveViewTest
  import Moon.AddressesFixtures

  @create_attrs %{
    name: "HUNTINGTON BEACH",
    street_address: "2100 Pierre-Dupuy Ave",
    city: "Montreal",
    province: "QC",
    postal_code: "H3C 3R5",
    country: "Canada",
    address_type: "port"
  }
  @update_attrs %{
    name: "Port of Montreal",
    street_address: "2100 Pierre-Dupuy Ave",
    city: "Montreal",
    province: "QC",
    postal_code: "H3C 3R5",
    country: "Canada",
    address_type: "port"
  }
  @invalid_attrs %{
    name: nil,
    street_address: nil,
    city: nil,
    province: nil,
    postal_code: nil,
    country: nil,
    address_type: "port"
  }

  setup :register_and_log_in_user

  defp create_address(%{scope: scope}) do
    address = address_fixture(scope)

    %{address: address}
  end

  describe "Index" do
    setup [:create_address]

    test "lists all addresses", %{conn: conn, address: address} do
      {:ok, _index_live, html} = live(conn, ~p"/addresses")

      assert html =~ "Listing Addresses"
      assert html =~ address.name
    end

    test "saves new address", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/addresses")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Address")
               |> render_click()
               |> follow_redirect(conn, ~p"/addresses/new")

      assert render(form_live) =~ "New Address"

      assert form_live
             |> form("#address-form", address: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#address-form", address: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/addresses")

      html = render(index_live)
      assert html =~ "Address created successfully"
      assert html =~ "Port of Montreal"
    end

    test "updates address in listing", %{conn: conn, address: address} do
      {:ok, index_live, _html} = live(conn, ~p"/addresses")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#addresses-#{address.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/addresses/#{address}/edit")

      assert render(form_live) =~ "Edit Address"

      assert form_live
             |> form("#address-form", address: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#address-form", address: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/addresses")

      html = render(index_live)
      assert html =~ "Address updated successfully"
      assert html =~ "Port of Montreal"
    end

    test "deletes address in listing", %{conn: conn, address: address} do
      {:ok, index_live, _html} = live(conn, ~p"/addresses")

      assert index_live |> element("#addresses-#{address.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#addresses-#{address.id}")
    end
  end

  describe "Show" do
    setup [:create_address]

    test "displays address", %{conn: conn, address: address} do
      {:ok, _show_live, html} = live(conn, ~p"/addresses/#{address}")

      assert html =~ "Show Address"
      assert html =~ address.name
    end

    test "updates address and returns to show", %{conn: conn, address: address} do
      {:ok, show_live, _html} = live(conn, ~p"/addresses/#{address}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/addresses/#{address}/edit?return_to=show")

      assert render(form_live) =~ "Edit Address"

      assert form_live
             |> form("#address-form", address: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#address-form", address: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/addresses/#{address}")

      html = render(show_live)
      assert html =~ "Address updated successfully"
      assert html =~ "Port of Montreal"
    end
  end
end
