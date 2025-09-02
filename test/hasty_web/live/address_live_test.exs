defmodule HastyWeb.AddressLiveTest do
  use HastyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Hasty.AddressesFixtures

  @create_attrs %{state: "some state", number: "some number", street: "some street", city: "some city", neighborhood: "some neighborhood", country: "some country", zip_code: "some zip_code"}
  @update_attrs %{state: "some updated state", number: "some updated number", street: "some updated street", city: "some updated city", neighborhood: "some updated neighborhood", country: "some updated country", zip_code: "some updated zip_code"}
  @invalid_attrs %{state: nil, number: nil, street: nil, city: nil, neighborhood: nil, country: nil, zip_code: nil}

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
      assert html =~ address.street
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
      assert html =~ "some street"
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
      assert html =~ "some updated street"
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
      assert html =~ address.street
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
      assert html =~ "some updated street"
    end
  end
end
