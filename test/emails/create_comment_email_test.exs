defmodule AccentTest.CreateCommentEmail do
  use ExUnit.Case

  test "create" do
    project = %Accent.Project{id: "ec44dc76-9c55-4f64-bb9b-4cf5ff0123ac", name: "My project name"}
    revision = %Accent.Revision{id: "ec44dc76-9c55-4f64-bb9b-4cf5ff0123ab", project: project}
    translation = %Accent.Translation{id: "dc44dc76-9c55-4f64-bb9b-4cf5ff0123ab", key: "My key", corrected_text: "FOO", revision: revision}
    user = %Accent.User{email: "test@test.com"}
    comment = %Accent.Comment{text: "This is a comment", translation: translation, user: user}
    emails = ["new@test.com", "foo@bar.test"]

    payload = %{
      "text" => comment.text,
      "translation" => %{"id" => translation.id, "key" => translation.key}
    }

    email = Accent.CreateCommentEmail.create(emails, user, project, payload)

    assert email.to == emails
    assert email.from == {"Accent", "accent-test@example.com"}
    assert email.subject == ~s(Accent – New comment on "#{project.name}")
    assert email.headers == %{"X-SMTPAPI" => ~s({"category": ["test", "accent-api-test"]})}

    assert email.html_body =~ user.email
    assert email.html_body =~ comment.text
    assert email.html_body =~ "The Accent Team"
    assert email.html_body =~ ~s(href="http://example.com/">http://example.com/</a>)
    assert email.html_body =~ ~s(href="http://example.com/app/projects/#{project.id}/translations/#{translation.id}/conversation">here</a>)

    assert email.text_body =~ user.email
    assert email.text_body =~ comment.text
    assert email.text_body =~ "The Accent Team"
    assert email.text_body =~ "(http://example.com/)"
    assert email.text_body =~ "(http://example.com/app/projects/#{project.id}/translations/#{translation.id}/conversation)"
  end
end
