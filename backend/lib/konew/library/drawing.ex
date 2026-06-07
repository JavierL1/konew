defmodule Konew.Library.Drawing do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          image_data: binary(),
          content_type: String.t(),
          user_id: integer(),
          user: Konew.Accounts.User.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "drawings" do
    field(:image_data, :binary)
    field(:content_type, :string)

    belongs_to(:user, Konew.Accounts.User)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(drawing, attrs, user_scope) do
    drawing
    |> cast(attrs, [:image_data, :content_type])
    |> put_change(:user_id, user_scope.user.id)
    |> validate_required([:image_data, :content_type, :user_id])
  end
end
