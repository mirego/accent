defmodule AccentTest.Scopes.Language do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Language
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Scopes.Language, as: LanguageScope

  setup do
    Repo.delete_all(Language)
    :ok
  end

  describe "from_search/2" do
    test "returns query ordered by most used languages when search is nil" do
      language1 = Factory.insert(Language, name: "French", slug: "fr")
      language2 = Factory.insert(Language, name: "English", slug: "en")
      _language3 = Factory.insert(Language, name: "Foo", slug: "foo")

      # Create more revisions for French to make it more "popular"
      Factory.insert_list(Revision, 3, language_id: language1.id)
      Factory.insert(Revision, language_id: language2.id)

      results =
        Language
        |> LanguageScope.from_search(nil)
        |> Repo.all()

      assert Enum.map(results, & &1.slug) == ["fr", "en", "foo"]
    end

    test "searches by exact slug match first" do
      Factory.insert(Language, name: "French", slug: "fr")
      Factory.insert(Language, name: "Frisian", slug: "frs")

      results =
        Language
        |> LanguageScope.from_search("fr")
        |> Repo.all()

      assert Enum.map(results, & &1.slug) == ["fr", "frs"]
    end

    test "searches by slug prefix second" do
      Factory.insert(Language, name: "Other", slug: "other")
      Factory.insert(Language, name: "French", slug: "fr")
      Factory.insert(Language, name: "Frisian", slug: "frs")

      results =
        Language
        |> LanguageScope.from_search("fr")
        |> Repo.all()

      assert Enum.map(results, & &1.slug) == ["fr", "frs"]
    end

    test "orders by slug length" do
      Factory.insert(Language, name: "French Regional", slug: "fr-reg")
      Factory.insert(Language, name: "French", slug: "fr")

      results =
        Language
        |> LanguageScope.from_search("fr")
        |> Repo.all()

      assert Enum.map(results, & &1.slug) == ["fr", "fr-reg"]
    end
  end
end
