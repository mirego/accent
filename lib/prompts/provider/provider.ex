defprotocol Accent.Prompts.Provider do
  def id(provider)
  def enabled?(provider)
  def completions(provider, prompt, user_input)
end
