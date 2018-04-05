defmodule Accent.GraphQL.Types.Viewer do
  use Absinthe.Schema.Notation

  import Accent.GraphQL.Helpers.Authorization

  object :viewer do
    field(:user, :user)

    field :projects, :projects do
      arg(:page, :integer)
      arg(:query, :string)

      resolve(viewer_authorize(:index_projects, &Accent.GraphQL.Resolvers.Project.list_viewer/3))
    end

    field :project, :project do
      arg(:id, non_null(:id))

      resolve(project_authorize(:show_project, &Accent.GraphQL.Resolvers.Project.show_viewer/3))
    end
  end
end
