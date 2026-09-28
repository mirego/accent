#!/usr/bin/env elixir
defmodule CICheck do
  @moduledoc false

  @checks [
    %{id: :compile, label: "Compilation without warnings", cmd: "make lint-compile", after: []},
    %{id: :test, label: "API tests", cmd: "make test-api", after: [:compile]},
    %{id: :format, label: "API code auto-formatting", cmd: "make lint-format", after: [:compile]},
    %{id: :credo, label: "API code lint", cmd: "make lint-credo", after: [:compile]},
    %{id: :dialyzer, label: "Dialyzer type check", cmd: "make dialyzer-check", after: [:compile]},
    %{id: :prettier, label: "Prettier auto-formatting", cmd: "make lint-prettier", after: []},
    %{id: :eslint, label: "Eslint code lint", cmd: "make lint-eslint", after: []},
    %{id: :hbs, label: "Handlebar template lint", cmd: "make lint-template-hbs", after: []},
    %{id: :tsc, label: "TypeScript type check", cmd: "make typescript-check", after: []}
  ]

  @tick_ms 100
  @spinner ~w(⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷)
  @label_width 38
  @rule IO.ANSI.faint() <> String.duplicate("-", 72) <> IO.ANSI.reset()

  def main do
    File.cd!(Path.expand("../..", __DIR__))

    state = %{
      checks: Enum.map(@checks, &Map.put(&1, :status, :pending)),
      refs: %{},
      tick: 0,
      tty?: tty?(),
      rendered?: false
    }

    IO.write([
      "\n",
      color(:bright, "  CI Checks"),
      "   ",
      color(:faint, "#{length(@checks)} checks"),
      "\n\n"
    ])

    state
    |> loop()
    |> report()
    |> System.halt()
  end

  defp loop(state) do
    state = state |> start_ready() |> render()

    if Enum.all?(state.checks, &(&1.status in [:pass, :fail])) do
      state
    else
      state |> await() |> loop()
    end
  end

  defp start_ready(state) do
    finished = for check <- state.checks, check.status in [:pass, :fail], into: MapSet.new(), do: check.id

    Enum.reduce(state.checks, state, fn check, acc ->
      if check.status == :pending and Enum.all?(check.after, &(&1 in finished)) do
        start(acc, check)
      else
        acc
      end
    end)
  end

  defp start(state, check) do
    task = Task.async(fn -> System.cmd("sh", ["-c", check.cmd], stderr_to_stdout: true) end)
    running = Map.put(%{check | status: :running}, :started_at, now())

    state
    |> put_check(running)
    |> put_in([:refs, task.ref], check.id)
  end

  defp await(%{refs: refs} = state) do
    receive do
      {ref, {output, code}} when is_map_key(refs, ref) ->
        Process.demonitor(ref, [:flush])
        {id, refs} = Map.pop(refs, ref)

        check =
          state.checks
          |> Enum.find(&(&1.id == id))
          |> Map.merge(%{
            status: if(code == 0, do: :pass, else: :fail),
            code: code,
            output: output,
            finished_at: now()
          })

        if !state.tty?, do: IO.puts(row(check, state.tick))

        put_check(%{state | refs: refs}, check)
    after
      @tick_ms -> %{state | tick: state.tick + 1}
    end
  end

  defp put_check(state, check) do
    %{state | checks: Enum.map(state.checks, &if(&1.id == check.id, do: check, else: &1))}
  end

  defp render(%{tty?: false} = state), do: state

  defp render(state) do
    cursor_up = if state.rendered?, do: IO.ANSI.cursor_up(length(state.checks)), else: ""
    rows = Enum.map(state.checks, &[IO.ANSI.clear_line(), row(&1, state.tick), "\n"])

    IO.write([cursor_up, rows])
    %{state | rendered?: true}
  end

  defp row(check, tick) do
    label = String.pad_trailing(check.label, @label_width)

    case check.status do
      :pending ->
        color(:faint, "    #{label}  waiting")

      :running ->
        spinner = Enum.at(@spinner, rem(tick, length(@spinner)))
        color(:yellow, "  #{spinner} #{label}  #{duration(now() - check.started_at)}")

      :pass ->
        color(:green, "  ✓ #{label}  PASS  #{duration(check.finished_at - check.started_at)}")

      :fail ->
        color(:red, "  ✗ #{label}  FAIL  #{duration(check.finished_at - check.started_at)}  (exit #{check.code})")
    end
  end

  defp report(state) do
    failures = Enum.filter(state.checks, &(&1.status == :fail))
    passed = length(state.checks) - length(failures)

    if failures != [] do
      IO.puts(["\n", color(:bright, "  Failure Details")])

      for check <- failures do
        output = check.output |> String.trim_trailing() |> String.replace(~r/^/m, "  ")
        IO.puts(["\n  ", color([:red, :bright], check.label), "\n", @rule, "\n", output, "\n", @rule])
      end
    end

    IO.puts(["\n", @rule])

    summary = [
      "  ",
      color(:yellow, String.pad_trailing("Summary", 20)),
      "  ",
      color([:green, :bright], "#{passed} passed")
    ]

    case failures do
      [] ->
        IO.puts([
          summary,
          "   all checks clean\n",
          @rule,
          "\n\n  ",
          color([:green, :bright], "All checks passed."),
          "\n"
        ])

        0

      _ ->
        failed = length(failures)

        IO.puts([
          summary,
          "   ",
          color([:red, :bright], "#{failed} failed"),
          "\n",
          @rule,
          "\n\n  ",
          color([:red, :bright], "#{failed} check(s) failed."),
          " Please fix before committing.\n"
        ])

        1
    end
  end

  defp duration(ms) do
    secs = div(ms, 1000)
    if secs < 60, do: "#{secs}s", else: "#{div(secs, 60)}m#{rem(secs, 60)}s"
  end

  defp color(attrs, text), do: IO.ANSI.format([List.wrap(attrs), text], true)

  defp tty? do
    :prim_tty.isatty(:stdout) == true
  rescue
    _ -> false
  end

  defp now, do: System.monotonic_time(:millisecond)
end

CICheck.main()
