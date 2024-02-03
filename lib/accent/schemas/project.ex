defmodule Accent.Project do
  @moduledoc false
  use Accent.Schema

  defmodule MachineTranslationsConfig do
    @moduledoc false
    use Cloak.Ecto.Map, vault: Accent.Vault
  end

  defmodule PromptConfig do
    @moduledoc false
    use Cloak.Ecto.Map, vault: Accent.Vault
  end

  schema "projects" do
    field(:name, :string)
    field(:main_color, :string)
    field(:logo, :string)
    field(:last_synced_at, :utc_datetime)
    field(:locked_file_operations, :boolean, default: false)

    field(:translations_count, :any, virtual: true, default: :not_loaded)
    field(:translated_count, :any, virtual: true, default: :not_loaded)
    field(:reviewed_count, :any, virtual: true, default: :not_loaded)
    field(:conflicts_count, :any, virtual: true, default: :not_loaded)

    has_many(:integrations, Accent.Integration)
    has_many(:revisions, Accent.Revision)
    has_many(:target_revisions, Accent.Revision, where: [master: false])
    has_many(:versions, Accent.Version)
    has_many(:operations, Accent.Operation)
    has_many(:prompts, Accent.Prompt)

    has_many(:collaborators, Accent.Collaborator,
      where: [role: {:in, ["reviewer", "admin", "developer", "owner", "translator"]}]
    )

    has_many(:all_collaborators, Accent.Collaborator)
    belongs_to(:language, Accent.Language)

    field(:machine_translations_config, MachineTranslationsConfig)
    field(:prompt_config, PromptConfig)

    field(:sync_lock_version, :integer, default: 1)

    timestamps()
  end
end
