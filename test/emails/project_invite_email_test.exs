defmodule AccentTest.ProjectInviteEmail do
  @moduledoc false
  use ExUnit.Case

  test "create" do
    user = %Accent.User{email: "test@test.com"}
    project = %Accent.Project{name: "test"}
    email_address = "new@test.com"

    email = Accent.ProjectInviteEmail.create(email_address, user, project)

    assert email.to == email_address
    assert email.from == {"Accent", "accent-test@example.com"}
    assert email.subject == ~s(Accent – Invitation to collaborate on "#{project.name}")
    assert email.headers == %{"X-SMTPAPI" => ~s({"category": ["test", "accent-api-test"]})}

    assert email.html_body =~ user.email
    assert email.html_body =~ project.name
    assert email.html_body =~ "The Accent Team"
    assert email.html_body =~ ~s(href="http://example.com/">http://example.com/</a>)
    assert email.html_body =~ ~s(href="http://example.com/">login</a>)

    assert email.text_body =~ user.email
    assert email.text_body =~ project.name
    assert email.text_body =~ "The Accent Team"
    assert email.text_body =~ "(http://example.com/)"
    assert email.text_body =~ "(http://example.com/)"
  end
end
