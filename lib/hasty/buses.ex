defmodule Hasty.Buses do
  @moduledoc """
  The Bus context.
  """ 

  import Ecto.Query, warn: :false
  alias Hasty.Repo

  alias Hasty.Buses.Bus

  @doc """
  Returns the list of buses.
  """
  def list_buses, do: Repo.all(Bus)

  @doc """
  Get a single Bus info.
  """
  def get_bus(id), do: Repo.get_by(Bus, id: id)

  @doc"""
  Return bus with line info.
  """
  def get_bus_with_line(id) do
    Repo.get(Bus, id)
    |> Repo.preload(:line)
  end

  @doc """
  Creates a bus.

  ## Examples

    iex> create_bus(%{field: value})
    {:ok, %Bus{}}

    iex> create_bus(%{field: bad_value})
    {:error, %Ecto.Changeset{}}
  """
  def create_bus(attrs) do
    case Repo.insert(Bus.changeset(%Bus{}, attrs)) do
      {:ok, bus} -> {:ok, bus}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates a bus.

  ## Examples

    iex> update_bus(bus, %{field: new_value})
    {:ok, %Bus{}}

    iex> update_bus(bus, %{field: bad_value})
    {:error, %Ecto.Changeset{}}
  """
  def update_bus(%Bus{} = bus, attrs) do
    case Repo.update(Bus.changeset(bus, attrs)) do
      {:ok, bus} -> {:ok, bus}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Delete a bus.

  ## Examples

    iex> delete_bus(bus)
    {:ok, %Bus{}}

    iex> delete_bus(bus)
    {:error, %Ecto.Changeset{}}
  """
  def delete_bus(%Bus{} = bus) do
    {:ok, bus = %Bus{}} =
      Repo.delete(bus)
    {:ok, bus}
  end

  @doc """
  Return an `%Ecto.Changeset{}` for tracking bus changes.

  ## Examples

    iex> change_bus(bus)
    %Ecto.Changeset{data: %Bus{}}
  """
  def change_bus(%Bus{} = bus, attrs \\ %{}) do
    Bus.changeset(bus, attrs)
  end
end
