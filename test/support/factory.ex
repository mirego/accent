defmodule Accent.Factory do
  @moduledoc false
  use Factori,
    repo: Accent.Repo,
    mappings: [
      Accent.Factory.Mappings.Document,
      Accent.Factory.Mappings.Operation,
      Accent.Factory.Mappings.Translation,
      Accent.Factory.Mappings.Project,
      Factori.Mapping.Embed,
      Factori.Mapping.Enum,
      Factori.Mapping.Faker
    ]

  defmodule Mappings do
    @moduledoc false
    defmodule Project do
      @moduledoc false
      @behaviour Factori.Mapping

      def match(%{table_name: "projects", name: :locked_file_operations}), do: false
    end

    defmodule Document do
      @moduledoc false
      @behaviour Factori.Mapping

      def match(%{table_name: "documents", name: :format}), do: "json"
      def match(%{table_name: "documents", name: :path}), do: "translations"
    end

    defmodule Operation do
      @moduledoc false
      @behaviour Factori.Mapping

      def match(%{table_name: "operations", name: :rollbacked}), do: false
      def match(%{table_name: "operations", name: :batch}), do: false
    end

    defmodule Translation do
      @moduledoc false
      @behaviour Factori.Mapping

      def match(%{table_name: "translations", name: :locked}), do: false
      def match(%{table_name: "translations", name: :removed}), do: false
    end
  end
end
