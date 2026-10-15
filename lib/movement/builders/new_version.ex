defmodule Movement.Builders.NewVersion do
  @moduledoc false
  @behaviour Movement.Builder

  alias Accent.Repo
  alias Accent.Scopes.Translation, as: TranslationScope
  alias Accent.Translation
  alias Movement.Builders.CorrectedTextOperations

  def build(%Movement.Context{assigns: assigns} = context) do
    translations =
      Translation
      |> TranslationScope.from_project(assigns[:project].id)
      |> TranslationScope.no_version()
      |> Repo.all()

    CorrectedTextOperations.build(context, translations, "version_new")
  end
end
