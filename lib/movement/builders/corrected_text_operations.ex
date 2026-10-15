defmodule Movement.Builders.CorrectedTextOperations do
  @moduledoc false

  import Movement.Context, only: [assign: 3]

  alias Movement.Mappers.Operation, as: OperationMapper

  @spec build(Movement.Context.t(), [Accent.Translation.t()], String.t()) :: Movement.Context.t()
  def build(%Movement.Context{operations: operations} = context, translations, action) do
    new_operations = Enum.map(translations, &OperationMapper.map_text(action, &1, &1.corrected_text))

    %{assign(context, :translations, translations) | operations: new_operations ++ operations}
  end
end
