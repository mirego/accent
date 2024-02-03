defmodule Movement.Persisters.OperationsUpdateAllDynamic do
  @moduledoc false
  import Ecto.Query

  alias Accent.Repo

  @uuid_fragment "SELECT * FROM unnest(?::uuid[], ?::uuid[]) AS t(a, b)"
  @text_text_bool_bool_fragment "SELECT * FROM unnest(?::uuid[], ?::text[], ?::text[], ?::boolean[], ?::boolean[]) AS t(a, b, c, d, e)"
  @text_text_text_bool_bool_fragment "SELECT * FROM unnest(?::uuid[], ?::text[], ?::text[], ?::text[], ?::boolean[], ?::boolean[]) AS t(a, b, c, d, e, f)"

  def update({{schema, [:text, :text, :boolean, :boolean], fields}, records}) do
    [bind_1, bind_2, bind_3, bind_4] = values_binding(records, fields)

    update_all(
      from(entries in schema,
        join:
          values_list in fragment(
            @text_text_bool_bool_fragment,
            ^ids_binding(records),
            ^bind_1,
            ^bind_2,
            ^bind_3,
            ^bind_4
          ),
        on: values_list.a == entries.id,
        update: [
          set: [
            {^Enum.at(fields, 0), values_list.b},
            {^Enum.at(fields, 1), values_list.c},
            {^Enum.at(fields, 2), values_list.d},
            {^Enum.at(fields, 3), values_list.e},
            updated_at: ^DateTime.utc_now(:second)
          ]
        ]
      )
    )
  end

  def update({{schema, [:uuid], fields}, records}) do
    [bind_1] = values_binding(records, fields)

    update_all(
      from(entries in schema,
        join:
          values_list in fragment(
            @uuid_fragment,
            ^ids_binding(records),
            ^bind_1
          ),
        on: values_list.a == entries.id,
        update: [set: [{^Enum.at(fields, 0), values_list.b}, updated_at: ^DateTime.utc_now(:second)]]
      )
    )
  end

  def update({{schema, [:text, :text, :text, :boolean, :boolean], fields}, records}) do
    [bind_1, bind_2, bind_3, bind_4, bind_5] = values_binding(records, fields)

    update_all(
      from(entries in schema,
        join:
          values_list in fragment(
            @text_text_text_bool_bool_fragment,
            ^ids_binding(records),
            ^bind_1,
            ^bind_2,
            ^bind_3,
            ^bind_4,
            ^bind_5
          ),
        on: values_list.a == entries.id,
        update: [
          set: [
            {^Enum.at(fields, 0), values_list.b},
            {^Enum.at(fields, 1), values_list.c},
            {^Enum.at(fields, 2), values_list.d},
            {^Enum.at(fields, 3), values_list.e},
            {^Enum.at(fields, 4), values_list.f},
            updated_at: ^DateTime.utc_now(:second)
          ]
        ]
      )
    )
  end

  defp update_all(query) do
    Repo.update_all(query, [])
  end

  defp ids_binding(records) do
    Enum.map(records, &Ecto.UUID.dump!(elem(&1, 0)))
  end

  defp values_binding(records, fields) do
    range = 0..(length(fields) - 1)
    for i <- range, do: Enum.map(records, &Enum.at(elem(&1, 1), i))
  end
end
