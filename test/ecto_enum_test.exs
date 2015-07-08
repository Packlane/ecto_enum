defmodule EctoEnumTest do
  use ExUnit.Case

  import Ecto.Changeset
  import Ecto.Enum
  defenum StatusEnum, registered: 0, active: 1, inactive: 2, archived: 3

  defmodule User do
    use Ecto.Schema
      use Ecto.Model

    schema "users" do
      field :status, StatusEnum
    end
  end

  alias Ecto.Integration.TestRepo

  test "accepts int, atom and string on save" do
    user = TestRepo.insert!(%User{status: 0})
    user = TestRepo.get(User, user.id)
    assert user.status == :registered

    user = TestRepo.update!(%{user|status: :active})
    user = TestRepo.get(User, user.id)
    assert user.status == :active

    user = TestRepo.update!(%{user|status: "Inactive"})
    user = TestRepo.get(User, user.id)
    assert user.status == :inactive

    TestRepo.insert!(%User{status: :archived})
    user = TestRepo.get_by(User, status: :archived)
    assert user.status == :archived
  end

  test "casts int and binary to atom" do
    %{changes: changes} = cast(%User{}, %{"status" => "active"}, ~w(status), [])
    assert changes.status == :active

    %{changes: changes} = cast(%User{}, %{"status" => 3}, ~w(status), [])
    assert changes.status == :archived
  end

  test "sets enum on load" do
    user = TestRepo.insert!(%User{enum_status: :active})
    user = TestRepo.get(User, user.id)
    assert user.status == 1
    assert user.enum_status == :active
    assert User.active?(user)
  end

  test "reflection functions" do
    assert User.__enums__(:status) == [registered: 0, active: 1, inactive: 2, archived: 3]
    assert User.__enums__(:enum_status) == [registered: 0, active: 1, inactive: 2, archived: 3]
  end
end

# TODO: test for ensuring that integer passed to field is within the provided options
# TODO: verify that list passed is of the expected format
