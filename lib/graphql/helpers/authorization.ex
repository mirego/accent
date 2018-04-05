defmodule Accent.GraphQL.Helpers.Authorization do
  import Accent.GraphQL.Plugins.Authorization

  alias Accent.{
    Project,
    Version,
    Translation,
    Revision,
    Collaborator,
    TranslationCommentsSubscription,
    Document,
    Operation,
    Integration,
    Repo
  }

  def viewer_authorize(_action, func) do
    fn
      %{user: nil}, _args, _info ->
        {:ok, nil}

      user, args, info ->
        func.(user, args, info)
    end
  end

  def project_authorize(action, func, id \\ :id) do
    fn
      project = %Project{}, args, info ->
        authorize(action, project.id, info, do: func.(project, args, info))

      _, args, info ->
        project = Repo.get(Project, args[id]) || %{id: nil}

        authorize(action, project.id, info, do: func.(project, args, info))
    end
  end

  def revision_authorize(action, func) do
    fn
      revision = %Revision{}, args, info ->
        authorize(action, revision.project_id, info, do: func.(revision, args, info))

      _, args, info ->
        revision =
          Revision
          |> Repo.get(args.id)
          |> Repo.preload(:language)

        authorize(action, revision.project_id, info, do: func.(revision, args, info))
    end
  end

  def version_authorize(action, func) do
    fn
      version = %Version{}, args, info ->
        authorize(action, version.project_id, info, do: func.(version, args, info))

      _, args, info ->
        version =
          Version
          |> Repo.get(args.id)

        authorize(action, version.project_id, info, do: func.(version, args, info))
    end
  end

  def translation_authorize(action, func) do
    fn
      translation = %Translation{}, args, info ->
        revision =
          case translation.revision do
            %Revision{} = revision ->
              revision

            _ ->
              translation |> Ecto.assoc(:revision) |> Repo.one()
          end

        authorize(action, revision.project_id, info, do: func.(translation, args, info))

      _, args, info ->
        id = args[:id] || args[:translation_id]

        translation =
          Translation
          |> Repo.get(id)
          |> Repo.preload(revision: [:project])

        authorize(action, translation.revision.project_id, info, do: func.(translation, args, info))
    end
  end

  def document_authorize(action, func) do
    fn _, args, info ->
      document = Repo.get(Document, args.id)

      authorize(action, document.project_id, info, do: func.(document, args, info))
    end
  end

  def operation_authorize(action, func) do
    fn _, args, info ->
      operation =
        Operation
        |> Repo.get(args[:id])
        |> Repo.preload([:revision, [translation: [:revision]]])

      project_id =
        case operation do
          %{translation: %{revision: %{project_id: id}}} -> id
          %{revision: %{project_id: id}} -> id
          %{project_id: id} -> id
          _ -> nil
        end

      authorize(action, project_id, info, do: func.(operation, args, info))
    end
  end

  def translation_comment_subscription_authorize(action, func) do
    fn _, args, info ->
      subscription =
        TranslationCommentsSubscription
        |> Repo.get(args.id)
        |> Repo.preload(translation: [:revision])

      authorize(action, subscription.translation.revision.project_id, info, do: func.(subscription, args, info))
    end
  end

  def collaborator_authorize(action, func) do
    fn _, args, info ->
      collaborator =
        Collaborator
        |> Repo.get(args.id)

      authorize(action, collaborator.project_id, info, do: func.(collaborator, args, info))
    end
  end

  def integration_authorize(action, func) do
    fn _, args, info ->
      integration =
        Integration
        |> Repo.get(args.id)

      authorize(action, integration.project_id, info, do: func.(integration, args, info))
    end
  end
end
