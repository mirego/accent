defmodule Accent.TelemetryUI do
  @moduledoc false
  import TelemetryUI.Metrics

  alias Accent.TelemetryUI.EctoPSQLExtras

  def config do
    [
      metrics: [
        {"HTTP", http_metrics(), ui_options: [metrics_class: "grid-cols-8 gap-4"]},
        {"GraphQL", graphql_metrics(), ui_options: [metrics_class: "grid-cols-8 gap-4"]},
        {"Absinthe", absinthe_metrics(), ui_options: [metrics_class: "grid-cols-8 gap-4"]},
        {"Oban", oban_metrics(), ui_options: [metrics_class: "grid-cols-8 gap-4"]},
        {"Ecto", ecto_metrics(), ui_options: [metrics_class: "grid-cols-8 gap-4"]},
        {"PSQL Extras", EctoPSQLExtras.all(Accent.Repo)},
        {"Accent", accent_metrics(), ui_options: [metrics_class: "grid-cols-8 gap-4"]},
        {"Lint", lint_metrics(), ui_options: [metrics_class: "grid-cols-8 gap-4"]},
        {"Language Tool", language_tool_metrics(), ui_options: [metrics_class: "grid-cols-8 gap-4"]},
        {"System", system_metrics()}
      ],
      theme: theme(),
      backend: backend()
    ]
  end

  def language_tool_metrics do
    [
      counter("accent.language_tool.check.stop.duration",
        description: "Number of spellchecks",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " checks"]
      ),
      count_over_time("accent.language_tool.check.stop.duration",
        description: "Number of spellchecks over time",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " checks"]
      ),
      average("accent.language_tool.check.stop.duration",
        description: "Spellchecks duration",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      average_over_time("accent.language_tool.check.stop.duration",
        description: "Spellchecks duration over time",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      count_over_time("accent.language_tool.check.stop.duration",
        description: "Spellchecks per language over time",
        tags: [:language_code],
        unit: {:native, :millisecond},
        ui_options: [unit: " checks"]
      ),
      count_list("accent.language_tool.check.stop.duration",
        description: "Count spellchecks by language",
        tags: [:language_code],
        unit: {:native, :millisecond},
        ui_options: [unit: " checks"]
      ),
      average_over_time("accent.language_tool.check.stop.duration",
        description: "Spellchecks duration per language",
        tags: [:language_code]
      )
    ]
  end

  def http_metrics do
    http_keep = &(&1[:route] not in ~w(/metrics /graphql))

    [
      counter("phoenix.router_dispatch.stop.duration",
        description: "Number of requests",
        keep: http_keep,
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " requests"]
      ),
      count_over_time("phoenix.router_dispatch.stop.duration",
        description: "Number of requests over time",
        keep: http_keep,
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " requests"]
      ),
      average("phoenix.router_dispatch.stop.duration",
        description: "Requests duration",
        keep: http_keep,
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      average_over_time("phoenix.router_dispatch.stop.duration",
        description: "Requests duration over time",
        keep: http_keep,
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      count_over_time("phoenix.router_dispatch.stop.duration",
        description: "HTTP requests count per route",
        keep: http_keep,
        tags: [:route],
        unit: {:native, :millisecond},
        ui_options: [unit: " requests"]
      ),
      count_list("phoenix.router_dispatch.stop.duration",
        description: "Count HTTP requests by route",
        keep: http_keep,
        tags: [:route],
        unit: {:native, :millisecond},
        ui_options: [unit: " requests"]
      ),
      average_over_time("phoenix.router_dispatch.stop.duration",
        description: "HTTP requests duration per route",
        keep: http_keep,
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      distribution("phoenix.router_dispatch.stop.duration",
        description: "Requests duration",
        keep: http_keep,
        unit: {:native, :millisecond},
        reporter_options: [buckets: [0, 100, 500, 2000]]
      )
    ]
  end

  defp oban_metrics do
    oban_worker_tag_values = fn metadata ->
      %{worker: metadata.job.worker}
    end

    oban_queue_tag_values = fn metadata ->
      %{queue: metadata.job.queue}
    end

    [
      counter("oban.job.stop.duration",
        description: "Number of jobs executed",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " jobs"]
      ),
      count_over_time("oban.job.stop.duration",
        description: "Number of jobs executed over time",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " jobs"]
      ),
      average("oban.job.stop.duration",
        description: "Jobs execution duration",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      average_over_time("oban.job.stop.duration",
        description: "Jobs execution duration over time",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      average("oban.job.stop.queue_time",
        description: "Jobs queue time",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      average_over_time("oban.job.stop.queue_time",
        description: "Jobs queue time over time",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      count_over_time("oban.job.stop.duration",
        description: "Jobs count per worker",
        tags: [:worker],
        tag_values: oban_worker_tag_values,
        unit: {:native, :millisecond},
        ui_options: [unit: " jobs"]
      ),
      count_list("oban.job.stop.duration",
        description: "Count jobs by worker",
        tags: [:worker],
        tag_values: oban_worker_tag_values,
        unit: {:native, :millisecond},
        ui_options: [unit: " jobs"]
      ),
      average_over_time("oban.job.stop.duration",
        description: "Jobs duration per worker",
        tags: [:worker],
        tag_values: oban_worker_tag_values,
        unit: {:native, :millisecond}
      ),
      count_over_time("oban.job.stop.duration",
        description: "Jobs count per queue",
        tags: [:queue],
        tag_values: oban_queue_tag_values,
        unit: {:native, :millisecond},
        ui_options: [unit: " jobs"]
      ),
      average_over_time("oban.job.stop.duration",
        description: "Jobs duration per queue",
        tags: [:queue],
        tag_values: oban_queue_tag_values,
        unit: {:native, :millisecond}
      ),
      counter("oban.job.exception.duration",
        description: "Number of job exceptions",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " exceptions"]
      ),
      count_over_time("oban.job.exception.duration",
        description: "Job exceptions over time",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " exceptions"]
      ),
      distribution("oban.job.stop.duration",
        description: "Jobs duration distribution",
        unit: {:native, :millisecond},
        reporter_options: [buckets: [0, 100, 500, 2000]]
      )
    ]
  end

  defp ecto_metrics do
    ecto_keep =
      &(&1[:source] not in [nil, ""] and not String.starts_with?(&1[:source], "oban") and
          not String.starts_with?(&1[:source], "telemetry_ui"))

    [
      average("accent.repo.query.total_time",
        description: "Database query total time",
        keep: ecto_keep,
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      average_over_time("accent.repo.query.total_time",
        description: "Database query total time over time",
        keep: ecto_keep,
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      average_list("accent.repo.query.total_time",
        description: "Database query total time per source",
        keep: ecto_keep,
        tags: [:source],
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-full", unit: " ms"]
      ),
      count_list("accent.repo.query.total_time",
        description: "Database query count per source",
        keep: ecto_keep,
        tags: [:source],
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-full", unit: " ms"]
      )
    ]
  end

  defp absinthe_metrics do
    absinthe_tag_values = fn metadata ->
      operation_name =
        metadata.blueprint.operations
        |> Enum.map(& &1.name)
        |> Enum.uniq()
        |> Enum.join(",")

      %{operation_name: operation_name}
    end

    list_keep = fn metadata ->
      metadata.measurements.duration > System.convert_time_unit(50, :millisecond, :native)
    end

    list_tag_values = fn metadata ->
      resolution_path = Enum.filter(Absinthe.Resolution.path(metadata.resolution), &is_binary/1)

      %{resolution_path: Enum.join(resolution_path, ".")}
    end

    [
      average("absinthe.execute.operation.stop.duration",
        description: "Absinthe operation duration",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      average_over_time("absinthe.execute.operation.stop.duration",
        description: "Absinthe operation duration over time",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      count_list("absinthe.execute.operation.stop.duration",
        description: "Count Absinthe executions per operation",
        tags: [:operation_name],
        tag_values: absinthe_tag_values,
        unit: {:native, :millisecond}
      ),
      average_over_time("absinthe.execute.operation.stop.duration",
        description: "Absinthe duration per operation",
        tags: [:operation_name],
        tag_values: absinthe_tag_values,
        unit: {:native, :millisecond}
      ),
      average_list("absinthe.resolve.field.stop.duration",
        description: "Absinthe field resolve",
        tags: [:resolution_path],
        keep: list_keep,
        tag_values: list_tag_values,
        unit: {:native, :millisecond}
      )
    ]
  end

  defp graphql_metrics do
    graphql_keep = &(&1[:route] in ~w(/graphql))

    graphql_tag_values = fn metadata ->
      operation_name =
        case metadata.conn.params do
          %{"_json" => json} ->
            json
            |> Enum.map(& &1["operationName"])
            |> Enum.uniq()
            |> Enum.join(",")

          _ ->
            nil
        end

      %{operation_name: operation_name}
    end

    [
      counter("graphql.router_dispatch.duration",
        event_name: [:phoenix, :router_dispatch, :stop],
        description: "Number of GraphQL requests",
        keep: graphql_keep,
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " requests"]
      ),
      count_over_time("graphql.router_dispatch.duration",
        event_name: [:phoenix, :router_dispatch, :stop],
        description: "Number of GraphQL requests over time",
        keep: graphql_keep,
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " requests"]
      ),
      average("graphql.router_dispatch.duration",
        event_name: [:phoenix, :router_dispatch, :stop],
        description: "GraphQL requests duration",
        keep: graphql_keep,
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      average_over_time("graphql.router_dispatch.duration",
        event_name: [:phoenix, :router_dispatch, :stop],
        description: "GraphQL requests duration over time",
        keep: graphql_keep,
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      count_over_time("graphql.router_dispatch.duration",
        event_name: [:phoenix, :router_dispatch, :stop],
        description: "GraphQL requests count per operation",
        keep: graphql_keep,
        tag_values: graphql_tag_values,
        tags: [:operation_name],
        unit: {:native, :millisecond},
        ui_options: [unit: " requests"],
        reporter_options: [class: "col-span-4", compare_value_scale: {"red", "green"}]
      ),
      counter("graphql.router_dispatch.duration",
        event_name: [:phoenix, :router_dispatch, :stop],
        description: "Count GraphQL requests by operation",
        keep: graphql_keep,
        tag_values: graphql_tag_values,
        tags: [:operation_name],
        unit: {:native, :millisecond},
        ui_options: [unit: " requests"],
        reporter_options: [class: "col-span-4"]
      ),
      average("graphql.router_dispatch.duration",
        event_name: [:phoenix, :router_dispatch, :stop],
        description: "GraphQL requests duration per operation",
        keep: graphql_keep,
        tag_values: graphql_tag_values,
        tags: [:operation_name],
        unit: {:native, :millisecond},
        reporter_options: [class: "col-span-4"]
      ),
      distribution("graphql.router_dispatch.duration",
        event_name: [:phoenix, :router_dispatch, :stop],
        description: "GraphQL requests duration",
        keep: graphql_keep,
        unit: {:native, :millisecond},
        reporter_options: [buckets: [0, 100, 500, 2000]]
      )
    ]
  end

  defp lint_metrics do
    [
      counter("accent.lint.stop.duration",
        description: "Lint executions",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " runs"]
      ),
      count_over_time("accent.lint.stop.duration",
        description: "Lint executions over time",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " runs"]
      ),
      average("accent.lint.stop.duration",
        description: "Lint duration",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      average_over_time("accent.lint.stop.duration",
        description: "Lint duration over time",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " ms", compare_value_scale: {"red", "green"}]
      )
    ]
  end

  defp accent_metrics do
    [
      counter_value("accent.sync.count",
        description: "Syncs executed",
        ui_options: [class: "col-span-3", unit: ""]
      ),
      counter_value("accent.merge.count",
        description: "Merges executed",
        ui_options: [class: "col-span-3", unit: ""]
      ),
      counter_value("accent.export.count",
        description: "Exports executed",
        ui_options: [class: "col-span-2", unit: ""]
      ),
      count_over_time("accent.sync.count",
        description: "Syncs over time",
        ui_options: [class: "col-span-3", unit: ""]
      ),
      count_over_time("accent.merge.count",
        description: "Merges over time",
        ui_options: [class: "col-span-3", unit: ""]
      ),
      count_over_time("accent.export.count",
        description: "Exports over time",
        ui_options: [class: "col-span-2", unit: ""]
      ),
      counter("accent.movement.persist.stop.duration",
        description: "Operations executed",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " operations"]
      ),
      count_over_time("accent.movement.persist.stop.duration",
        description: "Operations over time",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " operations"]
      ),
      average("accent.movement.persist.stop.duration",
        description: "Operations duration",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-3", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      average_over_time("accent.movement.persist.stop.duration",
        description: "Operations duration over time",
        unit: {:native, :millisecond},
        ui_options: [class: "col-span-5", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      count_over_time("accent.movement.persist.stop.duration",
        description: "Batch action over time",
        tags: [:batch_action],
        unit: {:native, :millisecond},
        ui_options: [unit: " operations"]
      ),
      count_list("accent.movement.persist.stop.duration",
        description: "Count operations by batch action",
        tags: [:batch_action],
        unit: {:native, :millisecond},
        ui_options: [unit: " operations"]
      ),
      average_over_time("accent.movement.persist.stop.duration",
        description: "Operations duration per batch action",
        tags: [:batch_action],
        unit: {:native, :millisecond}
      ),
      distribution("accent.movement.persist.stop.duration",
        description: "Operations duration distribution",
        unit: {:native, :millisecond},
        reporter_options: [buckets: [0, 100, 500, 2000, 10_000]]
      ),
      counter("accent.movement.migrate.stop.duration",
        description: "Operations executed",
        unit: {:native, :millisecond},
        keep: &(&1[:direction] == "up"),
        ui_options: [class: "col-span-3", unit: " ops"]
      ),
      count_over_time("accent.movement.migrate.stop.duration",
        description: "Operations over time",
        unit: {:native, :millisecond},
        keep: &(&1[:direction] == "up"),
        ui_options: [class: "col-span-5", unit: " ops"]
      ),
      average("accent.movement.migrate.stop.duration",
        description: "Operations duration",
        unit: {:native, :millisecond},
        keep: &(&1[:direction] == "up"),
        ui_options: [class: "col-span-3", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      average_over_time("accent.movement.migrate.stop.duration",
        description: "Operations duration over time",
        unit: {:native, :millisecond},
        keep: &(&1[:direction] == "up"),
        ui_options: [class: "col-span-5", unit: " ms", compare_value_scale: {"red", "green"}]
      ),
      count_over_time("accent.movement.migrate.stop.duration",
        description: "Operations per action over time",
        tags: [:action],
        keep: &(&1[:direction] == "up"),
        unit: {:native, :millisecond},
        ui_options: [unit: " ops"]
      ),
      count_list("accent.movement.migrate.stop.duration",
        description: "Count operations by action",
        tags: [:action],
        keep: &(&1[:direction] == "up"),
        unit: {:native, :millisecond},
        ui_options: [unit: " ops"]
      ),
      count_over_time("accent.movement.migrate.stop.duration",
        description: "Operations apply vs rollback over time",
        tags: [:direction],
        unit: {:native, :millisecond},
        ui_options: [unit: " ops"]
      ),
      count_list("accent.movement.migrate.stop.duration",
        description: "Count operations by direction",
        tags: [:direction],
        unit: {:native, :millisecond},
        ui_options: [unit: " ops"]
      )
    ]
  end

  defp system_metrics do
    [
      last_value("vm.memory.total",
        description: "Total memory",
        unit: {:byte, :megabyte},
        ui_options: [class: "col-span-2", unit: " MB"]
      ),
      last_value("vm.memory.processes",
        description: "Process memory",
        unit: {:byte, :megabyte},
        ui_options: [class: "col-span-2", unit: " MB"]
      ),
      last_value("vm.memory.binary",
        description: "Binary memory",
        unit: {:byte, :megabyte},
        ui_options: [class: "col-span-2", unit: " MB"]
      ),
      last_value("vm.memory.ets",
        description: "ETS memory",
        unit: {:byte, :megabyte},
        ui_options: [class: "col-span-2", unit: " MB"]
      ),
      last_value("vm.memory.atom",
        description: "Atom memory",
        unit: {:byte, :megabyte},
        ui_options: [class: "col-span-2", unit: " MB"]
      ),
      last_value("vm.memory.code",
        description: "Code memory",
        unit: {:byte, :megabyte},
        ui_options: [class: "col-span-2", unit: " MB"]
      ),
      last_value("vm.memory.system",
        description: "System memory",
        unit: {:byte, :megabyte},
        ui_options: [class: "col-span-2", unit: " MB"]
      ),
      last_value("vm.total_run_queue_lengths.total",
        description: "Run queue total length",
        ui_options: [class: "col-span-2"]
      ),
      last_value("vm.total_run_queue_lengths.cpu",
        description: "Run queue CPU length",
        ui_options: [class: "col-span-3"]
      ),
      last_value("vm.total_run_queue_lengths.io",
        description: "Run queue IO length",
        ui_options: [class: "col-span-3"]
      ),
      last_value("vm.system_counts.process_count",
        description: "Process count",
        ui_options: [class: "col-span-2", unit: " processes"]
      ),
      last_value("vm.system_counts.atom_count",
        description: "Atom count",
        ui_options: [class: "col-span-2", unit: " atoms"]
      ),
      last_value("vm.system_counts.port_count",
        description: "Port count",
        ui_options: [class: "col-span-2", unit: " ports"]
      )
    ]
  end

  defp theme do
    %{
      header_color: "#28cb87",
      primary_color: "#28cb87",
      title: "Accent metrics",
      share_key: "012345678912345",
      share_path: "/metrics-public",
      frame_options: [
        {:last_5_minutes, 5, :minute},
        {:last_30_minutes, 30, :minute},
        {:last_2_hours, 120, :minute},
        {:last_1_day, 1, :day},
        {:last_7_days, 7, :day},
        {:last_1_month, 1, :month},
        {:custom, 0, nil}
      ],
      logo: """
      <svg
        viewBox="0 0 480 480"
        xmlns="http://www.w3.org/2000/svg"
        fill-rule="evenodd"
        clip-rule="evenodd"
        stroke-linejoin="round"
        stroke-miterlimit="1.414"
        width="20"
        height="20"
      >
        <circle cx="240" cy="240" r="239.334" fill="#3dbc87" />
        <path
          d="M101.024 300.037l16.512 14.677s100.856-96.196 117.42-96.445c16.562-.25 126.59 92.77 126.59 92.77l17.43-15.6-116.5-142.19c-8.257-11.01-18.348-16.51-27.52-16.51-11.927 0-23.852 8.25-34.86 24.77l-99.072 138.52z"
          fill="#0f2f21"
          fill-rule="nonzero"
        />
      </svg>
      """
    }
  end

  defp backend do
    %TelemetryUI.Backend.EctoPostgres{
      repo: Accent.Repo,
      pruner_threshold: [months: -1],
      pruner_interval_ms: 84_000,
      max_buffer_size: 10_000,
      flush_interval_ms: 30_000,
      verbose: false
    }
  end
end
