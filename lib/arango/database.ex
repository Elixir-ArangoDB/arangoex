defmodule Arango.Database do
  @moduledoc "ArangoDB Database methods"

  alias Arango.Request

  defstruct [
    :id,
    :name,
    :isSystem,
    :path,
    :users
  ]
  use ExConstructor

  @type t :: %__MODULE__{
    id: String.t,
    name: String.t,
    isSystem: boolean,
    path: String.t,
    users: [String.t],
  }

  @doc """
  Create database

  POST /_api/database
  """
  @type create_database_user_opts :: [{:username, String.t} | {:passwd, String.t} | {:active, boolean} | {:extra, Map.t}]
  @type create_database_opts :: [{:name, String.t} | {:users, [create_database_user_opts]}]
  @spec create(create_database_opts) :: Arango.ok_error(any())
  def create(database \\ [])
  def create(%__MODULE__{name: name}), do: create(name: name)
  def create(opts) do
    %Request{
      endpoint: :database,
      system_only: true,
      http_method: :post,
      path: "database",
      body: opts |> Keyword.take([:name, :users]) |> Enum.into(%{}),
      ok_decoder: __MODULE__.PlainDecoder,
    }
  end

  @doc """
  Drop database

  DELETE /_api/database/{database-name}
  """
  @spec drop(String.t) :: Arango.ok_error(true)
  def drop(db_name) do
    %Request{
      endpoint: :database,
      system_only: true,
      http_method: :delete,
      path: "database/#{db_name}",
      ok_decoder: __MODULE__.PlainDecoder,
    }
  end

  @doc """
  Information about a database

  GET /_api/database/current
  """
  # @type show_database_opts :: [{:name, String.t}]
  @spec database() :: Arango.ok_error(t)
  def database() do
    %Request{
      endpoint: :database,
      http_method: :get,
      path: "database/current",
      ok_decoder: __MODULE__.DatabaseDecoder,
    }
  end

  @doc """
  List of databases

  GET /_api/database
  """
  @spec databases() :: Arango.ok_error([String.t])
  def databases() do
    %Request{
      endpoint: :database,
      system_only: true,
      http_method: :get,
      path: "database",
      ok_decoder: __MODULE__.PlainDecoder,
    }
  end

  @doc """
  List of accessible databases

  GET /_api/database/user
  """
  @spec user_databases() :: Arango.ok_error([String.t])
  def user_databases() do
    %Request{
      endpoint: :database,
      system_only: true,           # or just /_api? Same thing?
      http_method: :get,
      path: "database/user",
      ok_decoder: __MODULE__.PlainDecoder,
    }
  end

  defmodule DatabaseDecoder do
    alias Arango.Database

    @spec decode_ok(any()) :: Arango.ok_error(any())
    def decode_ok(%{"result" => result}), do: {:ok, Database.new(result)}
  end

  defmodule PlainDecoder do
    @spec decode_ok(any()) :: Arango.ok_error(any())
    def decode_ok(%{"result" => result}), do: {:ok, result}
  end
end
