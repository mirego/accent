defmodule Movement.EctoMigrationHelper do
  def update(struct, params), do: {:update, {struct, params}}

  def insert(struct), do: {:insert, struct}

  def insert_all(schema, struct), do: {:insert_all, {schema, struct}}

  def update_all_dynamic(struct, types, fields, values), do: {:update_all_dynamic, {struct.__struct__, struct.id, types, fields, values}}

  def update_all(struct, params), do: {:update_all, {struct.__struct__, struct.id, params}}
end
