package com.mirego.accent.languagetool

import java.io.BufferedReader
import java.io.InputStreamReader
import org.json.simple.JSONArray
import org.json.simple.JSONObject
import org.json.simple.parser.JSONParser
import org.languagetool.JLanguageTool
import org.languagetool.Languages
import org.languagetool.markup.AnnotatedTextBuilder
import org.languagetool.rules.RuleMatch

private const val LANG_WIDTH = 7
private const val MAX_REPLACEMENTS = 5

fun main(args: Array<String>) {
    val languages = ArrayList<String>()
    val disabledRuleIds = ArrayList<String>()
    val parser = JSONParser()

    var i = 0
    while (i < args.size) {
        when (args[i]) {
            "--languages" -> {
                val value = args.getOrNull(i + 1)
                if (value == null) {
                    println("Error: Missing languages.")
                    return
                }
                value.split(',').mapTo(languages) { it.trim() }
                i += 2
            }
            "--disabledRuleIds" -> {
                val value = args.getOrNull(i + 1)
                if (value == null) {
                    println("Error: Missing rule ids.")
                    return
                }
                disabledRuleIds.addAll(value.split(','))
                i += 2
            }
            else -> i += 1
        }
    }

    val tools = HashMap<String, JLanguageTool>(languages.size)
    for (code in languages) {
        val tool = JLanguageTool(Languages.getLanguageForShortCode(code))
        if (disabledRuleIds.isNotEmpty()) tool.disableRules(disabledRuleIds)
        tool.check("")
        tools[code] = tool
    }

    println(">")
    System.out.flush()

    val reader = BufferedReader(InputStreamReader(System.`in`, Charsets.UTF_8), 8192)
    while (true) {
        val input = reader.readLine() ?: break
        val languageShortCode = input.take(LANG_WIDTH).trim()
        val text = input.drop(LANG_WIDTH)
        val tool = tools[languageShortCode]

        val line = when {
            text.isEmpty() -> errorJson("invalid_input", text, languageShortCode)
            tool == null -> errorJson("unsupported_language", text, languageShortCode)
            else -> check(tool, parser, text, languageShortCode)
        }
        println(line)
    }
}

private fun check(tool: JLanguageTool, parser: JSONParser, text: String, languageShortCode: String): String {
    val parsed = parser.parse(text) as JSONObject
    val builder = AnnotatedTextBuilder()
    val markups = JSONArray()
    val rawItems = parsed["items"] as? List<*> ?: emptyList<Any>()

    for (entry in rawItems) {
        val item = entry as JSONObject
        val markup = item["markup"] as? String ?: ""
        if (markup.isNotEmpty()) {
            markups.add(markup)
            builder.addMarkup(markup, item["markupAs"] as? String ?: "x")
        } else {
            builder.addText(item["text"] as? String ?: "")
        }
    }

    val annotated = builder.build()
    val matches = tool.check(annotated)

    val response = JSONObject()
    response["text"] = annotated.textWithMarkup
    response["markups"] = markups
    response["language"] = languageShortCode
    val matchesList = JSONArray()
    for (match in matches) matchesList.add(matchJson(match))
    response["matches"] = matchesList
    return response.toJSONString()
}

@Suppress("UNCHECKED_CAST")
private fun matchJson(match: RuleMatch): JSONObject {
    val rule = JSONObject()
    rule["description"] = match.rule.description
    rule["id"] = match.specificRuleId

    val matchObject = JSONObject()
    matchObject["offset"] = match.fromPos
    matchObject["message"] = cleanSuggestion(match.message)
    matchObject["length"] = match.toPos - match.fromPos
    matchObject["replacements"] = replacementsJson(match)
    matchObject["rule"] = rule
    return matchObject
}

@Suppress("UNCHECKED_CAST")
private fun replacementsJson(match: RuleMatch): JSONArray {
    val replacements = JSONArray()
    for (replacement in match.suggestedReplacementObjects.take(MAX_REPLACEMENTS)) {
        val replacementObject = JSONObject()
        replacementObject["value"] = replacement.replacement
        replacements.add(replacementObject)
    }
    return replacements
}

private fun cleanSuggestion(message: String): String {
    if (!message.contains("<suggestion>")) return message
    return message.replace("<suggestion>", "\"").replace("</suggestion>", "\"")
}

@Suppress("UNCHECKED_CAST")
private fun errorJson(error: String, text: String, languageShortCode: String): String {
    val errorObject = JSONObject()
    errorObject["error"] = error
    errorObject["text"] = text
    errorObject["matches"] = JSONArray()
    errorObject["markups"] = JSONArray()
    errorObject["language"] = languageShortCode
    return errorObject.toJSONString()
}
