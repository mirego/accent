defmodule BambooSMTPAdapterWithTlsOptions do
  @moduledoc """
  Sends email using SMTP.

  Use this adapter to send emails through SMTP. This adapter requires
  that some settings are set in the config. See the example section below.

  *Sensitive credentials should not be committed to source control and are best kept in environment variables.
  Using `{:system, "ENV_NAME"}` configuration is read from the named environment variable at runtime.*

  ## Example config

      # In config/config.exs, or config.prod.exs, etc.
      config :my_app, MyApp.Mailer,
        adapter: Bamboo.SMTPAdapter,
        server: "smtp.domain",
        hostname: "www.mydomain.com",
        port: 1025,
        username: "your.name@your.domain", # or {:system, "SMTP_USERNAME"}
        password: "pa55word", # or {:system, "SMTP_PASSWORD"}
        tls: :if_available, # can be `:always` or `:never`
        allowed_tls_versions: [:"tlsv1", :"tlsv1.1", :"tlsv1.2"],
        # or {":system", ALLOWED_TLS_VERSIONS"} w/ comma separated values (e.g. "tlsv1.1,tlsv1.2")
        tls_log_level: :error,
        tls_verify: :verify_peer, # optional, can be `:verify_peer` or `:verify_none`
        tls_cacertfile: "/somewhere/on/disk", # optional, path to the ca truststore
        tls_cacerts: "…", # optional, DER-encoded trusted certificates
        tls_depth: 3, # optional, tls certificate chain depth
        tls_verify_fun: {&:ssl_verify_hostname.verify_fun/3, check_hostname: "example.com"}, # optional, tls verification function
        ssl: false, # can be `true`,
        retries: 1,
        no_mx_lookups: false, # can be `true`
        auth: :if_available # can be `:always`. If your smtp relay requires authentication set it to `:always`.

      # Define a Mailer. Maybe in lib/my_app/mailer.ex
      defmodule MyApp.Mailer do
        use Bamboo.Mailer, otp_app: :my_app
      end
  """

  @behaviour Bamboo.Adapter

  require Logger

  @required_configuration [:server, :port]
  @default_configuration %{
    tls: :if_available,
    ssl: false,
    retries: 1,
    transport: :gen_smtp_client,
    auth: :if_available
  }
  @tls_versions ~w(tlsv1 tlsv1.1 tlsv1.2)
  @log_levels [:critical, :error, :warning, :notice]
  @tls_verify [:verify_peer, :verify_none]

  defmodule SMTPError do
    @moduledoc false

    defexception [:message, :raw]

    def exception({reason, detail} = raw) do
      message = """
      There was a problem sending the email through SMTP.

      The error is #{inspect(reason)}

      More detail below:

      #{inspect(detail)}
      """

      %SMTPError{message: message, raw: raw}
    end
  end

  def deliver(email, config) do
    gen_smtp_config =
      to_gen_smtp_server_config(config)

    response =
      try do
        email
        |> Bamboo.Mailer.normalize_addresses()
        |> to_gen_smtp_message()
        |> config[:transport].send_blocking(gen_smtp_config)
      catch
        e ->
          raise SMTPError, {:not_specified, e}
      end

    handle_response(response)
  end

  @doc false
  def handle_config(config) do
    config
    |> check_required_configuration()
    |> put_default_configuration()
  end

  @doc false
  def supports_attachments?, do: true

  defp handle_response({:error, :no_credentials}) do
    {:error, "Username and password were not provided for authentication."}
  end

  defp handle_response({:error, _reason, detail}) do
    {:error, detail}
  end

  defp handle_response({:error, detail}) do
    {:error, detail}
  end

  defp handle_response(response) do
    {:ok, response}
  end

  defp add_bcc(body, %Bamboo.Email{bcc: []}) do
    body
  end

  defp add_bcc(body, %Bamboo.Email{bcc: recipients}) do
    add_smtp_header_line(body, :bcc, format_email_as_string(recipients, :bcc))
  end

  defp add_cc(body, %Bamboo.Email{cc: []}) do
    body
  end

  defp add_cc(body, %Bamboo.Email{cc: recipients}) do
    add_smtp_header_line(body, :cc, format_email_as_string(recipients, :cc))
  end

  defp add_custom_header(body, {key, value}) do
    add_smtp_header_line(body, key, value)
  end

  defp add_custom_headers(body, %Bamboo.Email{headers: headers}) do
    Enum.reduce(headers, body, &add_custom_header(&2, &1))
  end

  defp add_ending_header(body) do
    add_smtp_line(body, "")
  end

  defp add_ending_multipart(body, delimiter) do
    add_smtp_line(body, "--#{delimiter}--")
  end

  defp add_html_body(body, %Bamboo.Email{html_body: html_body}, _multi_part_delimiter) when html_body == nil do
    body
  end

  defp add_html_body(body, %Bamboo.Email{html_body: html_body}, multi_part_delimiter) do
    base64_html_body = base64_and_split(html_body)

    body
    |> add_multipart_delimiter(multi_part_delimiter)
    |> add_smtp_header_line("Content-Type", "text/html;charset=UTF-8")
    |> add_smtp_line("Content-Transfer-Encoding: base64")
    |> add_smtp_line("")
    |> add_smtp_line(base64_html_body)
  end

  defp add_from(body, %Bamboo.Email{from: from}) do
    add_smtp_header_line(body, :from, format_email_as_string(from, :from))
  end

  defp add_mime_header(body) do
    add_smtp_header_line(body, "MIME-Version", "1.0")
  end

  defp add_multipart_delimiter(body, delimiter) do
    add_smtp_line(body, "--#{delimiter}")
  end

  defp add_multipart_header(body, delimiter) do
    add_smtp_header_line(body, "Content-Type", ~s(multipart/alternative; boundary="#{delimiter}"))
  end

  defp add_multipart_mixed_header(body, delimiter) do
    add_smtp_header_line(body, "Content-Type", ~s(multipart/mixed; boundary="#{delimiter}"))
  end

  defp add_smtp_header_line(body, type, content) when is_list(content) do
    Enum.reduce(content, body, &add_smtp_header_line(&2, type, &1))
  end

  defp add_smtp_header_line(body, type, content) when is_atom(type) do
    add_smtp_header_line(body, String.capitalize(to_string(type)), content)
  end

  defp add_smtp_header_line(body, type, content) when is_binary(type) do
    add_smtp_line(body, "#{type}: #{content}")
  end

  defp add_smtp_line(body, content), do: body <> content <> "\r\n"

  defp add_subject(body, %Bamboo.Email{subject: subject}) when is_nil(subject) do
    add_smtp_header_line(body, :subject, "")
  end

  defp add_subject(body, %Bamboo.Email{subject: subject}) do
    add_smtp_header_line(body, :subject, rfc822_encode(subject))
  end

  defp rfc822_encode(content) do
    "=?UTF-8?B?#{Base.encode64(content)}?="
  end

  defp rfc2231_encode(content) do
    "UTF-8''#{URI.encode(content)}"
  end

  def base64_and_split(data) do
    data
    |> Base.encode64()
    |> Stream.unfold(&String.split_at(&1, 76))
    |> Enum.take_while(&(&1 != ""))
    |> Enum.join("\r\n")
  end

  defp add_text_body(body, %Bamboo.Email{text_body: text_body}, _multi_part_delimiter) when text_body == nil do
    body
  end

  defp add_text_body(body, %Bamboo.Email{text_body: text_body}, multi_part_delimiter) do
    body
    |> add_multipart_delimiter(multi_part_delimiter)
    |> add_smtp_header_line("Content-Type", "text/plain;charset=UTF-8")
    |> add_smtp_line("")
    |> add_smtp_line(text_body)
  end

  defp add_attachment_header(body, attachment) do
    case attachment.content_id do
      nil ->
        add_common_attachment_header(body, attachment)

      cid ->
        body
        |> add_common_attachment_header(attachment)
        |> add_smtp_line("Content-ID: <#{cid}>")
    end
  end

  defp add_common_attachment_header(body, %{content_type: content_type} = attachment)
       when content_type == "message/rfc822" do
    <<random::size(32)>> = :crypto.strong_rand_bytes(4)
    rfc2231_encoded_filename = rfc2231_encode(attachment.filename)

    body
    |> add_smtp_line("Content-Type: #{attachment.content_type}; name*=#{rfc2231_encoded_filename}")
    |> add_smtp_line("Content-Disposition: attachment; filename*=#{rfc2231_encoded_filename}")
    |> add_smtp_line("X-Attachment-Id: #{random}")
  end

  defp add_common_attachment_header(body, attachment) do
    <<random::size(32)>> = :crypto.strong_rand_bytes(4)
    rfc2231_encoded_filename = rfc2231_encode(attachment.filename)

    body
    |> add_smtp_line("Content-Type: #{attachment.content_type}; name*=#{rfc2231_encoded_filename}")
    |> add_smtp_line("Content-Disposition: attachment; filename*=#{rfc2231_encoded_filename}")
    |> add_smtp_line("Content-Transfer-Encoding: base64")
    |> add_smtp_line("X-Attachment-Id: #{random}")
  end

  defp add_attachment_body(body, data) do
    data =
      if String.contains?(body, "Content-Type: message/rfc822") do
        data
      else
        base64_and_split(data)
      end

    add_smtp_line(body, data)
  end

  defp add_attachment(nil, _), do: ""

  defp add_attachment(attachment, multi_part_mixed_delimiter) do
    ""
    |> add_multipart_delimiter(multi_part_mixed_delimiter)
    |> add_attachment_header(attachment)
    |> add_smtp_line("")
    |> add_attachment_body(attachment.data)
  end

  defp add_attachments(body, %Bamboo.Email{attachments: nil}, _), do: body

  defp add_attachments(body, %Bamboo.Email{attachments: attachments}, multi_part_mixed_delimiter) do
    attachment_part =
      Enum.map(attachments, fn attachment -> add_attachment(attachment, multi_part_mixed_delimiter) end)

    "#{body}#{attachment_part}"
  end

  defp add_to(body, %Bamboo.Email{to: recipients}) do
    add_smtp_header_line(body, :to, format_email_as_string(recipients, :to))
  end

  defp aggregate_errors(config, key, errors) do
    config
    |> Map.fetch(key)
    |> build_error(key, errors)
  end

  defp apply_default_configuration({:ok, value}, _default, config) when value != nil do
    config
  end

  defp apply_default_configuration(_not_found_value, {key, default_value}, config) do
    Map.put_new(config, key, default_value)
  end

  defp generate_multi_part_delimiter do
    <<random1::size(32), random2::size(32), random3::size(32)>> = :crypto.strong_rand_bytes(12)
    "----=_Part_#{random1}_#{random2}.#{random3}"
  end

  defp body(%Bamboo.Email{} = email) do
    multi_part_delimiter = generate_multi_part_delimiter()
    multi_part_mixed_delimiter = generate_multi_part_delimiter()

    ""
    |> add_subject(email)
    |> add_from(email)
    |> add_bcc(email)
    |> add_cc(email)
    |> add_to(email)
    |> add_custom_headers(email)
    |> add_mime_header()
    |> add_multipart_mixed_header(multi_part_mixed_delimiter)
    |> add_ending_header()
    |> add_multipart_delimiter(multi_part_mixed_delimiter)
    |> add_multipart_header(multi_part_delimiter)
    |> add_ending_header()
    |> add_text_body(email, multi_part_delimiter)
    |> add_html_body(email, multi_part_delimiter)
    |> add_ending_multipart(multi_part_delimiter)
    |> add_attachments(email, multi_part_mixed_delimiter)
    |> add_ending_multipart(multi_part_mixed_delimiter)
  end

  defp build_error({:ok, value}, _key, errors) when value != nil, do: errors

  defp build_error(_not_found_value, key, errors) do
    ["Key #{key} is required for SMTP Adapter" | errors]
  end

  defp check_required_configuration(config) do
    @required_configuration
    |> Enum.reduce([], &aggregate_errors(config, &1, &2))
    |> raise_on_missing_configuration(config)
  end

  defp puny_encode(email) do
    [local_part, domain_part] = String.split(email, "@")
    Enum.join([local_part, :idna.utf8_to_ascii(domain_part)], "@")
  end

  defp format_email({nil, email}, _format), do: puny_encode(email)
  defp format_email({name, email}, true), do: "#{rfc822_encode(name)} <#{puny_encode(email)}>"
  defp format_email({_name, email}, false), do: puny_encode(email)

  defp format_email(emails, format) when is_list(emails) do
    Enum.map(emails, &format_email(&1, format))
  end

  defp format_email(email, type, format \\ true) do
    email
    |> Bamboo.Formatter.format_email_address(type)
    |> format_email(format)
  end

  defp format_email_as_string(emails) when is_list(emails) do
    Enum.join(emails, ", ")
  end

  defp format_email_as_string(email) do
    email
  end

  defp format_email_as_string(email, type) do
    email
    |> format_email(type)
    |> format_email_as_string()
  end

  defp from_without_format(%Bamboo.Email{from: from}) do
    format_email(from, :from, false)
  end

  defp put_default_configuration(config) do
    Enum.reduce(@default_configuration, config, &put_default_configuration(&2, &1))
  end

  defp put_default_configuration(config, {key, _default_value} = default) do
    config
    |> Map.fetch(key)
    |> apply_default_configuration(default, config)
  end

  defp raise_on_missing_configuration([], config), do: config

  defp raise_on_missing_configuration(errors, config) do
    formatted_errors = Enum.map_join(errors, "\n", &"* #{&1}")

    raise ArgumentError, """
    The following settings have not been found in your settings:

    #{formatted_errors}

    They are required to make the SMTP adapter work. Here you configuration:

    #{inspect(config)}
    """
  end

  defp to_without_format(%Bamboo.Email{} = email) do
    email
    |> Bamboo.Email.all_recipients()
    |> format_email(:to, false)
  end

  defp to_gen_smtp_message(%Bamboo.Email{} = email) do
    {from_without_format(email), to_without_format(email), body(email)}
  end

  defp to_gen_smtp_server_config(config) do
    Enum.reduce(config, [], &to_gen_smtp_server_config/2)
  end

  defp to_gen_smtp_server_config({:server, value}, config) when is_binary(value) do
    [{:relay, value} | config]
  end

  defp to_gen_smtp_server_config({:username, value}, config) when is_binary(value) do
    [{:username, value} | config]
  end

  defp to_gen_smtp_server_config({:password, value}, config) when is_binary(value) do
    [{:password, value} | config]
  end

  defp to_gen_smtp_server_config({:tls, "if_available"}, config) do
    [{:tls, :if_available} | config]
  end

  defp to_gen_smtp_server_config({:tls, "always"}, config) do
    [{:tls, :always} | config]
  end

  defp to_gen_smtp_server_config({:tls, "never"}, config) do
    [{:tls, :never} | config]
  end

  defp to_gen_smtp_server_config({:tls, value}, config) when is_atom(value) do
    [{:tls, value} | config]
  end

  defp to_gen_smtp_server_config({:tls_options, value}, config) do
    Keyword.put(config, :tls_options, value)
  end

  defp to_gen_smtp_server_config({:allowed_tls_versions, value}, config) when is_binary(value) do
    Keyword.update(config, :tls_options, [{:versions, string_to_tls_versions(value)}], fn c ->
      [{:versions, string_to_tls_versions(value)} | c]
    end)
  end

  defp to_gen_smtp_server_config({:allowed_tls_versions, value}, config) when is_list(value) do
    Keyword.update(config, :tls_options, [{:versions, value}], fn c ->
      [{:versions, value} | c]
    end)
  end

  defp to_gen_smtp_server_config({:tls_log_level, value}, config) when value in @log_levels do
    Keyword.update(config, :tls_options, [{:log_level, value}], fn c ->
      [{:log_level, value} | c]
    end)
  end

  defp to_gen_smtp_server_config({:tls_verify, value}, config) when value in @tls_verify do
    Keyword.update(config, :tls_options, [{:verify, value}], fn c -> [{:verify, value} | c] end)
  end

  defp to_gen_smtp_server_config({:tls_cacertfile, value}, config) when is_binary(value) do
    Keyword.update(config, :tls_options, [{:cacertfile, value}], fn c ->
      [{:cacertfile, value} | c]
    end)
  end

  defp to_gen_smtp_server_config({:tls_cacerts, value}, config) when is_binary(value) do
    Keyword.update(config, :tls_options, [{:cacerts, value}], fn c -> [{:cacerts, value} | c] end)
  end

  defp to_gen_smtp_server_config({:tls_depth, value}, config) when is_integer(value) and value >= 0 do
    Keyword.update(config, :tls_options, [{:depth, value}], fn c -> [{:depth, value} | c] end)
  end

  defp to_gen_smtp_server_config({:tls_verify_fun, value}, config) when is_tuple(value) do
    Keyword.update(config, :tls_options, [{:verify_fun, value}], fn c ->
      [{:verify_fun, value} | c]
    end)
  end

  defp to_gen_smtp_server_config({:port, value}, config) when is_binary(value) do
    [{:port, String.to_integer(value)} | config]
  end

  defp to_gen_smtp_server_config({:port, value}, config) when is_integer(value) do
    [{:port, value} | config]
  end

  defp to_gen_smtp_server_config({:ssl, "true"}, config) do
    [{:ssl, true} | config]
  end

  defp to_gen_smtp_server_config({:ssl, "false"}, config) do
    [{:ssl, false} | config]
  end

  defp to_gen_smtp_server_config({:ssl, value}, config) when is_boolean(value) do
    [{:ssl, value} | config]
  end

  defp to_gen_smtp_server_config({:retries, value}, config) when is_binary(value) do
    [{:retries, String.to_integer(value)} | config]
  end

  defp to_gen_smtp_server_config({:retries, value}, config) when is_integer(value) do
    [{:retries, value} | config]
  end

  defp to_gen_smtp_server_config({:hostname, value}, config) when is_binary(value) do
    [{:hostname, value} | config]
  end

  defp to_gen_smtp_server_config({:no_mx_lookups, "true"}, config) do
    [{:no_mx_lookups, true} | config]
  end

  defp to_gen_smtp_server_config({:no_mx_lookups, "false"}, config) do
    [{:no_mx_lookups, false} | config]
  end

  defp to_gen_smtp_server_config({:no_mx_lookups, value}, config) when is_boolean(value) do
    [{:no_mx_lookups, value} | config]
  end

  defp to_gen_smtp_server_config({:auth, "if_available"}, config) do
    [{:auth, :if_available} | config]
  end

  defp to_gen_smtp_server_config({:auth, "always"}, config) do
    [{:auth, :always} | config]
  end

  defp to_gen_smtp_server_config({:auth, value}, config) when is_atom(value) do
    [{:auth, value} | config]
  end

  defp to_gen_smtp_server_config({:sockopts, value}, config) do
    [{:sockopts, value} | config]
  end

  defp to_gen_smtp_server_config({conf, {:system, var}}, config) do
    to_gen_smtp_server_config({conf, System.get_env(var)}, config)
  end

  defp to_gen_smtp_server_config({_key, _value}, config) do
    config
  end

  defp string_to_tls_versions(version_string) do
    version_string
    |> String.split(",")
    |> Enum.filter(&(&1 in @tls_versions))
    |> Enum.map(&String.to_atom/1)
  end
end
