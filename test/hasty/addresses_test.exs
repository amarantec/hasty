defmodule Hasty.AddressesTest do
  use Hasty.DataCase

  alias Hasty.Addresses

  describe "addresses" do
    alias Hasty.Addresses.Address

    import Hasty.AccountsFixtures, only: [user_scope_fixture: 0]
    import Hasty.AddressesFixtures

    @invalid_attrs %{state: nil, number: nil, street: nil, city: nil, neighborhood: nil, country: nil, zip_code: nil}

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
      valid_attrs = %{state: "some state", number: "some number", street: "some street", city: "some city", neighborhood: "some neighborhood", country: "some country", zip_code: "some zip_code"}
      scope = user_scope_fixture()

      assert {:ok, %Address{} = address} = Addresses.create_address(scope, valid_attrs)
      assert address.state == "some state"
      assert address.number == "some number"
      assert address.street == "some street"
      assert address.city == "some city"
      assert address.neighborhood == "some neighborhood"
      assert address.country == "some country"
      assert address.zip_code == "some zip_code"
      assert address.user_id == scope.user.id
    end

    test "create_address/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Addresses.create_address(scope, @invalid_attrs)
    end

    test "update_address/3 with valid data updates the address" do
      scope = user_scope_fixture()
      address = address_fixture(scope)
      update_attrs = %{state: "some updated state", number: "some updated number", street: "some updated street", city: "some updated city", neighborhood: "some updated neighborhood", country: "some updated country", zip_code: "some updated zip_code"}

      assert {:ok, %Address{} = address} = Addresses.update_address(scope, address, update_attrs)
      assert address.state == "some updated state"
      assert address.number == "some updated number"
      assert address.street == "some updated street"
      assert address.city == "some updated city"
      assert address.neighborhood == "some updated neighborhood"
      assert address.country == "some updated country"
      assert address.zip_code == "some updated zip_code"
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
      assert {:error, %Ecto.Changeset{}} = Addresses.update_address(scope, address, @invalid_attrs)
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
