defmodule Hasty.Lines do
  @moduledoc """
  The Line context.
  """

  import Ecto.Query, warn: :false
  alias Hasty.Repo

  alias Hasty.Lines.Line

  @doc """
  Return the list of available Lines
  """
  def list_lines, do: Repo.all(Line)

  @doc """
  Get a single Line info
  """
  def get_line(id), do: Repo.get_by(Line, id: id)

  @doc """
  Create a line.

  ## Example
    
    iex> create_line(%{field: value})
    {:ok, %Line{}}

    iex> create_line(%{field: bad_value})
    {:error, %Ecto.Changeset{}}
  """
  def create_line(attrs) do
    case Repo.insert(Line.changeset(%Line{}, attrs)) do
      {:ok, line} -> {:ok, line}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Update a line.

  ## Examples

    iex> update_line(line, %{field: new_value})
    {:ok, %Line{}}

    iex> update_line(line, %{field: bad_value})
    {:error, %Ecto.Changeset{}}
  """
  def update_line(%Line{} = line, attrs) do
    case Repo.update(Line.changeset(line, attrs)) do
      {:ok, line} -> {:ok, line}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Delete a line

  ## Examples
    
    iex> delete_line(line)
    {:ok, %Line{}}

    iex> delete_line(line)
    {:error, %Ecto.Changeset{}}
  """
  def delete_line(%Line{} = line) do
    {:ok, line = %Line{}} =
      Repo.delete(line)
    {:ok, line}
  end

  @doc """
  Return an `%Ecto.Changeset{}` for tracking line changes.

  ## Examples

    iex> change_line(line)
    %Ecto.Changeset{data: %Line{}}
  """
  def change_line(%Line{} = line, attrs \\ %{}) do
    Line.changeset(line, attrs)
  end
end
