defmodule Hasty.Contacts do
  @moduledoc """
  The Contacts context.
  """

  import Ecto.Query, warn: false
  alias Hasty.Repo

  alias Hasty.Contacts.Contact
  alias Hasty.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any contact changes.

  The broadcasted messages match the pattern:

    * {:created, %Contact{}}
    * {:updated, %Contact{}}
    * {:deleted, %Contact{}}

  """
  def subscribe_contacts(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Hasty.PubSub, "user:#{key}:contacts")
  end

  defp broadcast_contact(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Hasty.PubSub, "user:#{key}:contacts", message)
  end

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts(scope)
      [%Contact{}, ...]

  """
  def list_contacts(%Scope{} = scope) do
    Repo.all_by(Contact, user_id: scope.user.id)
  end

  @doc """
  Gets a single contact.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!(scope, 123)
      %Contact{}

      iex> get_contact!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_contact!(%Scope{} = scope, id) do
    Repo.get_by!(Contact, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a contact.

  ## Examples

      iex> create_contact(scope, %{field: value})
      {:ok, %Contact{}}

      iex> create_contact(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact(%Scope{} = scope, attrs) do
    with {:ok, contact = %Contact{}} <-
           %Contact{}
           |> Contact.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_contact(scope, {:created, contact})
      {:ok, contact}
    end
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(scope, contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(scope, contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact(%Scope{} = scope, %Contact{} = contact, attrs) do
    true = contact.user_id == scope.user.id

    with {:ok, contact = %Contact{}} <-
           contact
           |> Contact.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_contact(scope, {:updated, contact})
      {:ok, contact}
    end
  end

  @doc """
  Deletes a contact.

  ## Examples

      iex> delete_contact(scope, contact)
      {:ok, %Contact{}}

      iex> delete_contact(scope, contact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact(%Scope{} = scope, %Contact{} = contact) do
    true = contact.user_id == scope.user.id

    with {:ok, contact = %Contact{}} <-
           Repo.delete(contact) do
      broadcast_contact(scope, {:deleted, contact})
      {:ok, contact}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Examples

      iex> change_contact(scope, contact)
      %Ecto.Changeset{data: %Contact{}}

  """
  def change_contact(%Scope{} = scope, %Contact{} = contact, attrs \\ %{}) do
    true = contact.user_id == scope.user.id

    Contact.changeset(contact, attrs, scope)
  end
end
