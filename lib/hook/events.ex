defmodule Accent.Hook.Events do
  @moduledoc false
  path_wildcard = Path.join(Path.dirname(__ENV__.file), "events/*.ex")
  paths = Path.wildcard(path_wildcard)
  paths_hash = :erlang.md5(paths)

  @callback registered_events :: [String.t()] | :all

  event_modules =
    for name <- paths do
      Module.concat(__MODULE__, Phoenix.Naming.camelize(Path.basename(name, ".ex")))
    end

  @event_modules event_modules

  def available do
    @event_modules
  end

  def __mix_recompile__? do
    paths = Path.wildcard(unquote(path_wildcard))
    :erlang.md5(paths) != unquote(paths_hash)
  end
end
