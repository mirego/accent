defmodule Accent.GraphQL.Types.Project do
  @moduledoc false
  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]
  import Accent.GraphQL.Helpers.Authorization
  import Accent.GraphQL.Helpers.Fields

  object :projects do
    field(:meta, non_null(:pagination_meta))
    field(:entries, list_of(:project))
    field(:nodes, list_of(:project))
  end

  object :project_translated_text do
    field(:provider, non_null(:string))
    field(:error, :string)
    field(:text, :string)
  end

  object :machine_translations_config do
    field(:provider, non_null(:string))
    field(:enabled_actions, non_null(list_of(non_null(:string))))
    field(:use_platform, non_null(:boolean))
    field(:use_config_key, non_null(:boolean))
  end

  object :prompt_config do
    field(:provider, non_null(:string))
  end

  object :project do
    field(:id, :id)
    field(:name, :string)
    field(:main_color, :string)
    field(:last_synced_at, :datetime)
    field(:logo, :string)

    field(:translations_count, non_null(:integer))
    field(:translated_count, non_null(:integer))
    field(:conflicts_count, non_null(:integer))
    field(:reviewed_count, non_null(:integer))

    field(:machine_translations_config, :machine_translations_config,
      resolve: fn project, _, _ ->
        if project.machine_translations_config do
          {:ok,
           %{
             provider: project.machine_translations_config["provider"],
             enabled_actions: project.machine_translations_config["enabled_actions"] || [],
             use_platform: project.machine_translations_config["use_platform"],
             use_config_key: not is_nil(project.machine_translations_config["config"]["key"])
           }}
        else
          {:ok, nil}
        end
      end
    )

    field(:prompt_config, :prompt_config,
      resolve: fn project, _, _ ->
        if project.prompt_config do
          {:ok,
           %{
             provider: project.prompt_config["provider"]
           }}
        else
          {:ok, nil}
        end
      end
    )

    field :last_activity, :activity do
      arg(:action, :string)
      resolve(&Accent.GraphQL.Resolvers.Project.last_activity/3)
    end

    field(:is_file_operations_locked, non_null(:boolean), resolve: field_alias(:locked_file_operations))

    field :translated_text, :project_translated_text do
      arg(:text, non_null(:string))
      arg(:source_language_slug, :string)
      arg(:target_language_slug, non_null(:string))

      resolve(
        project_authorize(
          :machine_translations_translate,
          &Accent.GraphQL.Resolvers.MachineTranslation.translate_text/3
        )
      )
    end

    field :lint_translations, list_of(non_null(:lint_translation)) do
      arg(:query, :string)
      arg(:revision_id, :id, default_value: nil)
      arg(:rule_ids, list_of(non_null(:id)), default_value: [])
      resolve(project_authorize(:lint, &Accent.GraphQL.Resolvers.Project.lint_translations/3))
    end

    field :api_tokens, list_of(non_null(:api_token)) do
      resolve(
        project_authorize(
          :list_project_api_tokens,
          &Accent.GraphQL.Resolvers.APIToken.list_project/3
        )
      )
    end

    field :viewer_permissions, list_of(:string) do
      resolve(project_authorize(:index_permissions, &Accent.GraphQL.Resolvers.Permission.list_project/3))
    end

    field :collaborators, list_of(:collaborator) do
      resolve(project_authorize(:index_collaborators, dataloader(Accent.Collaborator)))
    end

    field :prompts, list_of(:prompt) do
      resolve(project_authorize(:index_prompt, dataloader(Accent.Prompt)))
    end

    field(:language, :language, resolve: dataloader(Accent.Language))
    field(:integrations, list_of(:project_integration), resolve: dataloader(Accent.Integration))

    field :document, :document do
      arg(:id, non_null(:id))

      resolve(project_authorize(:show_document, &Accent.GraphQL.Resolvers.Document.show_project/3))
    end

    field :documents, :documents do
      arg(:page, :integer)
      arg(:page_size, :integer)
      arg(:exclude_empty_translations, :boolean, default_value: true)

      resolve(project_authorize(:index_documents, &Accent.GraphQL.Resolvers.Document.list_project/3))
    end

    field :translations, :translations do
      arg(:page, :integer)
      arg(:page_size, :integer)
      arg(:order, :string)
      arg(:document, :id)
      arg(:version, :id)
      arg(:query, :string)
      arg(:is_conflicted, :boolean)
      arg(:is_text_empty, :boolean)
      arg(:is_text_not_empty, :boolean)
      arg(:is_added_last_sync, :boolean)
      arg(:is_commented_on, :boolean)

      resolve(
        project_authorize(
          :index_translations,
          &Accent.GraphQL.Resolvers.Translation.list_project/3
        )
      )
    end

    field :activities, :activities do
      arg(:page, :integer)
      arg(:page_size, :integer)
      arg(:action, :string)
      arg(:is_batch, :boolean)
      arg(:user_id, :id)
      arg(:version_id, :id)

      resolve(
        project_authorize(
          :index_project_activities,
          &Accent.GraphQL.Resolvers.Activity.list_project/3
        )
      )
    end

    field :comments, :comments do
      arg(:page, :integer)
      arg(:page_size, :integer)

      resolve(project_authorize(:index_comments, &Accent.GraphQL.Resolvers.Comment.list_project/3))
    end

    field :translation, :translation do
      arg(:id, non_null(:id))

      resolve(project_authorize(:show_translation, &Accent.GraphQL.Resolvers.Translation.show_project/3))
    end

    field :activity, :activity do
      arg(:id, non_null(:id))

      resolve(project_authorize(:show_activity, &Accent.GraphQL.Resolvers.Activity.show_project/3))
    end

    field :revision, :revision do
      arg(:id, :id)
      arg(:version_id, :id)

      resolve(project_authorize(:show_revision, &Accent.GraphQL.Resolvers.Revision.show_project/3))
    end

    field :revisions, list_of(:revision) do
      arg(:version_id, :id)
      resolve(project_authorize(:index_revisions, &Accent.GraphQL.Resolvers.Revision.list_project/3))
    end

    field :versions, :versions do
      arg(:page, :integer)
      arg(:page_size, :integer)

      resolve(project_authorize(:index_versions, &Accent.GraphQL.Resolvers.Version.list_project/3))
    end
  end
end
