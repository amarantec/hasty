defmodule Hasty.AddressesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hasty.Addresses` context.
  """

  @doc """
  Generate a address.
  """
  def address_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        city: "some city",
        country: "some country",
        neighborhood: "some neighborhood",
        number: "some number",
        state: "some state",
        street: "some street",
        zip_code: "some zip_code"
      })

    {:ok, address} = Hasty.Addresses.create_address(scope, attrs)
    address
  end
end
