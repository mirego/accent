# Merge and unmerge files to be "core translations" compliant and Accent compliant.

# ## Merge
# The file used in this command contains en and fr translations and outputs
# "key" => value in the specified language.
#
# Given the file en.json:
# {"key": "foo"}
# Given the file fr.json:
# {"key": "bar"}
# ruby core.rb merge en.json fr.json
# {
#   "key": {
#     "en": "bar",
#     "fr": "foo"
#   }
# }
#
# ## Unmerge
# The file used in this command contains en and fr translations and outputs
# "key" => value in the specified language.
#
# Given the file:
# {
#   "key": {
#     "en": "bar",
#     "fr": "foo"
#   }
# }
# `ruby core.rb unmerge file.json fr`
#
# {
#   "key": "foo"
# }

require 'json'

if ARGV[0] === 'merge'
  en_json = JSON.parse(File.read(ARGV[1]))
  fr_json = JSON.parse(File.read(ARGV[2]))

  output = en_json.each_with_object({}) { |(key, value), memo| memo[key] = {fr: fr_json[key], en: value} }
  puts JSON.pretty_generate(output)
end

if ARGV[0] === 'unmerge'
  output = JSON.parse(File.read(ARGV[1])).each_with_object({}) { |(key, value), memo| memo[key] = value[ARGV[2]] }
  puts JSON.pretty_generate(output)
end
