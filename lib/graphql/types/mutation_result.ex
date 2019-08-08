defmodule Accent.GraphQL.Types.MutationResult do
  use Absinthe.Schema.Notation

  object :mutated_translation do
    field(:translation, :translation)
    field(:errors, list_of(:string))
  end

  object :mutated_project do
    field(:project, :project)
    field(:errors, list_of(:string))
  end

  object :mutated_version do
    field(:version, :version)
    field(:errors, list_of(:string))
  end

  object :mutated_revision do
    field(:revision, :revision)
    field(:errors, list_of(:string))
  end

  object :mutated_collaborator do
    field(:collaborator, :collaborator)
    field(:errors, list_of(:string))
  end

  object :mutated_project_integration do
    field(:project_integration, :project_integration)
    field(:errors, list_of(:string))
  end

  object :mutated_comment do
    field(:comment, :comment)
    field(:errors, list_of(:string))
  end

  object :mutated_document do
    field(:document, :document)
    field(:errors, list_of(:string))
  end

  object :mutated_operation do
    field(:operation, :boolean)
    field(:errors, list_of(:string))
  end

  object :mutated_translation_comments_subscription do
    field(:translation_comments_subscription, :translation_comments_subscription)
    field(:errors, list_of(:string))
  end
end
