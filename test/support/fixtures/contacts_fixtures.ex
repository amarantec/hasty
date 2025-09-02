defmodule Hasty.ContactsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hasty.Contacts` context.
  """

  @doc """
  Generate a contact.
  """
  def contact_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        ddd: "some ddd",
        ddi: "some ddi",
        phone_number: "some phone_number"
      })

    {:ok, contact} = Hasty.Contacts.create_contact(scope, attrs)
    contact
  end
end
