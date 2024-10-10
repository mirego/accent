defmodule Accent.GraphQL.Types.Viewer do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  alias Accent.GraphQL.Resolvers.Project

  object :viewer do
    field(:user, :user, resolve: fn user, _, _ -> {:ok, user} end)

    field :permissions, list_of(:string) do
      resolve(viewer_authorize(:index_permissions, &Accent.GraphQL.Resolvers.Permission.list_viewer/3))
    end

    field :access_token, :string do
      resolve(&Accent.GraphQL.Resolvers.Viewer.show_access_token/3)
    end

    field :projects, :projects do
      arg(:page, :integer)
      arg(:page_size, :integer)
      arg(:query, :string)
      arg(:node_ids, list_of(non_null(:id)))

      resolve(viewer_authorize(:index_projects, &Project.list_viewer/3))
    end

    field :project, :project do
      arg(:id, :id, default_value: nil)

      resolve(project_authorize(:show_project, &Project.show_viewer/3))
    end
  end
end
