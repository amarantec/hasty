defmodule Hasty.ContactsTest do
  use Hasty.DataCase

  alias Hasty.Contacts

  describe "contacts" do
    alias Hasty.Contacts.Contact

    import Hasty.AccountsFixtures, only: [user_scope_fixture: 0]
    import Hasty.ContactsFixtures

    @invalid_attrs %{ddi: nil, ddd: nil, phone_number: nil}

    test "list_contacts/1 returns all scoped contacts" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      contact = contact_fixture(scope)
      other_contact = contact_fixture(other_scope)
      assert Contacts.list_contacts(scope) == [contact]
      assert Contacts.list_contacts(other_scope) == [other_contact]
    end

    test "get_contact!/2 returns the contact with given id" do
      scope = user_scope_fixture()
      contact = contact_fixture(scope)
      other_scope = user_scope_fixture()
      assert Contacts.get_contact!(scope, contact.id) == contact
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(other_scope, contact.id) end
    end

    test "create_contact/2 with valid data creates a contact" do
      valid_attrs = %{ddi: "some ddi", ddd: "some ddd", phone_number: "some phone_number"}
      scope = user_scope_fixture()

      assert {:ok, %Contact{} = contact} = Contacts.create_contact(scope, valid_attrs)
      assert contact.ddi == "some ddi"
      assert contact.ddd == "some ddd"
      assert contact.phone_number == "some phone_number"
      assert contact.user_id == scope.user.id
    end

    test "create_contact/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Contacts.create_contact(scope, @invalid_attrs)
    end

    test "update_contact/3 with valid data updates the contact" do
      scope = user_scope_fixture()
      contact = contact_fixture(scope)
      update_attrs = %{ddi: "some updated ddi", ddd: "some updated ddd", phone_number: "some updated phone_number"}

      assert {:ok, %Contact{} = contact} = Contacts.update_contact(scope, contact, update_attrs)
      assert contact.ddi == "some updated ddi"
      assert contact.ddd == "some updated ddd"
      assert contact.phone_number == "some updated phone_number"
    end

    test "update_contact/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      contact = contact_fixture(scope)

      assert_raise MatchError, fn ->
        Contacts.update_contact(other_scope, contact, %{})
      end
    end

    test "update_contact/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      contact = contact_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Contacts.update_contact(scope, contact, @invalid_attrs)
      assert contact == Contacts.get_contact!(scope, contact.id)
    end

    test "delete_contact/2 deletes the contact" do
      scope = user_scope_fixture()
      contact = contact_fixture(scope)
      assert {:ok, %Contact{}} = Contacts.delete_contact(scope, contact)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(scope, contact.id) end
    end

    test "delete_contact/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      contact = contact_fixture(scope)
      assert_raise MatchError, fn -> Contacts.delete_contact(other_scope, contact) end
    end

    test "change_contact/2 returns a contact changeset" do
      scope = user_scope_fixture()
      contact = contact_fixture(scope)
      assert %Ecto.Changeset{} = Contacts.change_contact(scope, contact)
    end
  end
end
