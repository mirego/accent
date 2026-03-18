defmodule AccentTest.Scopes.Language do
  @moduledoc false
  use Accent.RepoCase, async: true

  alias Accent.Collaborator
  alias Accent.Language
  alias Accent.Project
  alias Accent.Repo
  alias Accent.Revision
  alias Accent.Scopes.Language, as: LanguageScope
  alias Accent.User

  setup do
    Repo.delete_all(Language)
    :ok
  end

  describe "from_search/3 without user" do
    test "returns query ordered by most used languages when search is nil" do
      language1 = Factory.insert(Language, name: "French", slug: "fr")
      language2 = Factory.insert(Language, name: "English", slug: "en")
      _language3 = Factory.insert(Language, name: "Foo", slug: "foo")

      Factory.insert_list(Revision, 3, language_id: language1.id)
      Factory.insert(Revision, language_id: language2.id)

      results =
        Language
        |> LanguageScope.from_search(nil, nil)
        |> Repo.all()

      assert Enum.map(results, & &1.slug) == ["fr", "en", "foo"]
    end

    test "searches by exact slug match first" do
      Factory.insert(Language, name: "French", slug: "fr")
      Factory.insert(Language, name: "Frisian", slug: "frs")

      results =
        Language
        |> LanguageScope.from_search(nil, "fr")
        |> Repo.all()

      assert Enum.map(results, & &1.slug) == ["fr", "frs"]
    end

    test "searches by slug prefix second" do
      Factory.insert(Language, name: "Other", slug: "other")
      Factory.insert(Language, name: "French", slug: "fr")
      Factory.insert(Language, name: "Frisian", slug: "frs")

      results =
        Language
        |> LanguageScope.from_search(nil, "fr")
        |> Repo.all()

      assert Enum.map(results, & &1.slug) == ["fr", "frs"]
    end

    test "orders by slug length" do
      Factory.insert(Language, name: "French Regional", slug: "fr-reg")
      Factory.insert(Language, name: "French", slug: "fr")

      results =
        Language
        |> LanguageScope.from_search(nil, "fr")
        |> Repo.all()

      assert Enum.map(results, & &1.slug) == ["fr", "fr-reg"]
    end
  end

  describe "from_search/3 with user" do
    test "orders by languages from projects the user collaborates on" do
      user = Factory.insert(User, bot: false)

      language_fr = Factory.insert(Language, name: "French", slug: "fr")
      language_de = Factory.insert(Language, name: "German", slug: "de")

      project_mine = Factory.insert(Project)
      project_other = Factory.insert(Project)
      project_other2 = Factory.insert(Project)
      project_other3 = Factory.insert(Project)

      Factory.insert(Collaborator, user_id: user.id, project_id: project_mine.id)

      Factory.insert(Revision, language_id: language_fr.id, project_id: project_mine.id)
      Factory.insert(Revision, language_id: language_de.id, project_id: project_other.id)
      Factory.insert(Revision, language_id: language_de.id, project_id: project_other2.id)
      Factory.insert(Revision, language_id: language_de.id, project_id: project_other3.id)

      results =
        Language
        |> LanguageScope.from_search(user, nil)
        |> Repo.all()

      slugs = Enum.map(results, & &1.slug)
      fr_index = Enum.find_index(slugs, &(&1 == "fr"))
      de_index = Enum.find_index(slugs, &(&1 == "de"))

      assert fr_index < de_index
    end

    test "falls back to alphabetical for languages not in the user's projects" do
      user = Factory.insert(User, bot: false)

      Factory.insert(Language, name: "Aardvark", slug: "aa")
      Factory.insert(Language, name: "Zebra", slug: "zz")

      results =
        Language
        |> LanguageScope.from_search(user, nil)
        |> Repo.all()

      slugs = Enum.map(results, & &1.slug)
      assert Enum.find_index(slugs, &(&1 == "aa")) < Enum.find_index(slugs, &(&1 == "zz"))
    end
  end
end
