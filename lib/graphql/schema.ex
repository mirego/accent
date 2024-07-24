defmodule Accent.GraphQL.Schema do
  @moduledoc false
  use Absinthe.Schema

  alias Accent.Repo

  # Scalars
  import_types(Accent.GraphQL.DatetimeScalar)

  # Types
  import_types(AbsintheErrorPayload.ValidationMessageTypes)
  import_types(Accent.GraphQL.Types.APIToken)
  import_types(Accent.GraphQL.Types.AuthenticationProvider)
  import_types(Accent.GraphQL.Types.DocumentFormat)
  import_types(Accent.GraphQL.Types.Role)
  import_types(Accent.GraphQL.Types.Viewer)
  import_types(Accent.GraphQL.Types.Pagination)
  import_types(Accent.GraphQL.Types.User)
  import_types(Accent.GraphQL.Types.Translation)
  import_types(Accent.GraphQL.Types.Revision)
  import_types(Accent.GraphQL.Types.Integration)
  import_types(Accent.GraphQL.Types.Project)
  import_types(Accent.GraphQL.Types.Prompt)
  import_types(Accent.GraphQL.Types.Activity)
  import_types(Accent.GraphQL.Types.Document)
  import_types(Accent.GraphQL.Types.Collaborator)
  import_types(Accent.GraphQL.Types.Comment)
  import_types(Accent.GraphQL.Types.Language)
  import_types(Accent.GraphQL.Types.Version)
  import_types(Accent.GraphQL.Types.MutationResult)
  import_types(Accent.GraphQL.Types.Lint)

  @version Application.compile_env!(:accent, :version)

  object :application do
    field(:version, :string,
      resolve: fn _, _ ->
        {:ok, @version}
      end
    )
  end

  query do
    field :application, :application do
      resolve(fn _, _ -> {:ok, %{}} end)
    end

    field :viewer, :viewer do
      resolve(&Accent.GraphQL.Resolvers.Viewer.show/3)
    end

    field :languages, non_null(:languages) do
      arg(:query, :string)
      arg(:page_size, :integer, default_value: 30)

      resolve(&Accent.GraphQL.Resolvers.Language.list/3)
    end

    field :authentication_providers, non_null(list_of(non_null(:authentication_provider))) do
      resolve(&Accent.GraphQL.Resolvers.AuthenticationProvider.list/3)
    end

    field :roles, non_null(list_of(non_null(:role_item))) do
      resolve(&Accent.GraphQL.Resolvers.Role.list/3)
    end

    field :document_formats, non_null(list_of(non_null(:document_format_item))) do
      resolve(&Accent.GraphQL.Resolvers.DocumentFormat.list/3)
    end
  end

  mutation do
    # Mutation types
    import_types(Accent.GraphQL.Mutations.APIToken)
    import_types(Accent.GraphQL.Mutations.MachineTranslationsConfig)
    import_types(Accent.GraphQL.Mutations.Translation)
    import_types(Accent.GraphQL.Mutations.Comment)
    import_types(Accent.GraphQL.Mutations.Collaborator)
    import_types(Accent.GraphQL.Mutations.Document)
    import_types(Accent.GraphQL.Mutations.Revision)
    import_types(Accent.GraphQL.Mutations.Project)
    import_types(Accent.GraphQL.Mutations.Prompt)
    import_types(Accent.GraphQL.Mutations.Integration)
    import_types(Accent.GraphQL.Mutations.Operation)
    import_types(Accent.GraphQL.Mutations.Version)

    import_fields(:prompt_mutations)
    import_fields(:api_token_mutations)
    import_fields(:machine_translations_config_mutations)
    import_fields(:comment_mutations)
    import_fields(:translation_mutations)
    import_fields(:collaborator_mutations)
    import_fields(:document_mutations)
    import_fields(:revision_mutations)
    import_fields(:project_mutations)
    import_fields(:integration_mutations)
    import_fields(:operation_mutations)
    import_fields(:version_mutations)
  end

  def context(absinthe_context) do
    default_query = fn queryable, _ -> queryable end
    default_source = Dataloader.Ecto.new(Repo, query: default_query)

    loader =
      Enum.reduce(
        [
          Accent.AccessToken,
          Accent.Collaborator,
          Accent.Comment,
          Accent.Document,
          Accent.Integration,
          Accent.Language,
          Accent.Operation,
          Accent.Project,
          Accent.Prompt,
          Accent.Revision,
          Accent.Translation,
          Accent.TranslationCommentsSubscription,
          Accent.User,
          Accent.Version
        ],
        Dataloader.new(),
        &Dataloader.add_source(&2, &1, default_source)
      )

    Map.put(absinthe_context, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def middleware(middleware, _, _) do
    [NewRelic.Absinthe.Middleware] ++ middleware
  end

  def absinthe_pipeline(config, opts) do
    config
    |> Absinthe.Plug.default_pipeline(opts)
    |> Absinthe.Pipeline.insert_after(
      Absinthe.Phase.Document.Result,
      Accent.GraphQL.ErrorReporting
    )
  end
end
