defmodule Accent.GraphQL.Resolvers.Comment do
  alias Accent.Scopes.Comment, as: CommentScope

  alias Accent.{
    Comment,
    GraphQL.Paginated,
    Hook,
    Plugs.GraphQLContext,
    Project,
    Repo,
    Translation
  }

  @typep comment_operation :: {:ok, %{comment: Comment.t() | nil, errors: [String.t()] | nil}}

  @spec create(Translation.t(), %{text: String.t()}, GraphQLContext.t()) :: comment_operation
  def create(translation, args, info) do
    comment_params = %{
      "text" => args.text,
      "user_id" => info.context[:conn].assigns[:current_user].id,
      "translation_id" => translation.id
    }

    changeset = Comment.changeset(%Comment{}, comment_params)

    case Repo.insert(changeset) do
      {:ok, comment} ->
        comment = Repo.preload(comment, [:user, translation: [revision: :project]])

        Accent.Hook.notify(%Hook.Context{
          event: "create_comment",
          project: comment.translation.revision.project,
          user: info.context[:conn].assigns[:current_user],
          payload: %{
            comment: comment
          }
        })

        {:ok, %{comment: comment, errors: nil}}

      {:error, _reason} ->
        {:ok, %{comment: nil, errors: ["unprocessable_entity"]}}
    end
  end

  @spec list_project(Project.t(), %{page: number()}, GraphQLContext.t()) :: {:ok, Paginated.t(Comment.t())}
  def list_project(project, args, _) do
    Comment
    |> CommentScope.from_project(project.id)
    |> Paginated.paginate(args)
    |> Paginated.format()
    |> (&{:ok, &1}).()
  end

  @spec list_translation(Translation.t(), %{page: number()}, GraphQLContext.t()) :: {:ok, Paginated.t(Comment.t())}
  def list_translation(translation, args, _) do
    translation
    |> Ecto.assoc(:comments)
    |> CommentScope.default_order()
    |> Paginated.paginate(args)
    |> Paginated.format()
    |> (&{:ok, &1}).()
  end
end
