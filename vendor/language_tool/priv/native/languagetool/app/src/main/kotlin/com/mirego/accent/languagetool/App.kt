package com.mirego.accent.languagetool

import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader
import java.util.*
import java.util.concurrent.*
import org.json.simple.*
import org.languagetool.*
import org.languagetool.language.*
import org.languagetool.rules.*
import org.languagetool.markup.AnnotatedTextBuilder;

import kotlinx.serialization.*
import kotlinx.serialization.json.*

@Serializable
data class Base(val items: Array<Item>)

@Serializable
data class Item(val markup: String = "", val text: String = "", val markupAs: String = "x")

fun main(args: Array<String>) {
    val reader = BufferedReader(InputStreamReader(System.`in`))
    val tools = HashMap<String, JLanguageTool>()
    val languages = ArrayList<String>()
    val disabledRuleIds = ArrayList<String>()

    for (i in args.indices) {
        when (args[i]) {
            "--languages" -> {
                if (i + 1 < args.size) {
                    val codes = args[i + 1].split(",")
                    for (code in codes) {
                        languages.add(code.trim())
                    }
                } else {
                    println("Error: Missing languages.")
                    return
                }
            }
            "--disabledRuleIds" -> {
                if (i + 1 < args.size) {
                    val ids = args[i + 1].split(",")
                    for (id in ids) {
                        disabledRuleIds.add(id)
                    }
                } else {
                    println("Error: Missing rule ids.")
                    return
                }
            }
        }
    }

    for (code in languages) {
        val globalConfig = GlobalConfig()
        val userConfig = UserConfig()

        val lt =
            JLanguageTool(
                Languages.getLanguageForShortCode(code),
                ArrayList(),
                null,
                null,
                globalConfig,
                userConfig
            )
        for (id in disabledRuleIds) {
            lt.disableRule(id)
        }

        lt.check("")
        tools[code] = lt
    }

    var input: String?

    println(">")

    while (true) {
        input = reader.readLine()
        if (input == null) break
        val languageShortCode = input.substring(0, Math.min(7, input.length)).trim()
        val text = input.substring(Math.min(7, input.length))
        val langTool = tools[languageShortCode]

        if (text.length == 0) {
            printError("invalid_input", text, languageShortCode)
            continue
        }

        if (langTool == null) {
            printError("unsupported_language", text, languageShortCode)
            continue
        }

        val parsedText = Json.decodeFromString<Base>(text)
        val annotatedBuilder = AnnotatedTextBuilder()
        val markups = JSONArray()

        for (item in parsedText.items) {
          if (item.markup != "") {
            markups.add(item.markup)
            annotatedBuilder.addMarkup(item.markup, item.markupAs);
          } else {
            annotatedBuilder.addText(item.text);
          }
        }

        val annotatedText = annotatedBuilder.build()
        val matches = langTool.check(annotatedText)
        val responseObject = JSONObject()

        responseObject.put("text", annotatedText.getTextWithMarkup())
        responseObject.put("markups", markups)
        responseObject.put("language", languageShortCode)

        val matchesList = JSONArray()

        for (match in matches) {
            val matchObject = JSONObject()
            matchObject.put("offset", match.fromPos)
            matchObject.put("message", cleanSuggestion(match.message))
            matchObject.put("length", match.toPos - match.fromPos)

            matchObject.put("replacements", getReplacements(match))
            matchObject.put("rule", getRule(match))

            matchesList.add(matchObject)
        }

        responseObject.put("matches", matchesList)

        println(responseObject.toString())
    }
}

@Throws(IOException::class)
private fun printError(error: String, text: String, languageShortCode: String) {
    val errorObject = JSONObject()
    errorObject.put("error", error)
    errorObject.put("text", text)
    errorObject.put("matches", JSONArray())
    errorObject.put("markups", JSONArray())
    errorObject.put("language", languageShortCode)
    println(errorObject.toString())
}

@Throws(IOException::class)
private fun getRule(match: RuleMatch): JSONObject {
    val rule = match.rule
    val ruleObject = JSONObject()
    ruleObject.put("description", rule.description)
    ruleObject.put("id", match.specificRuleId)
    return ruleObject
}

@Throws(IOException::class)
private fun getReplacements(match: RuleMatch): JSONArray {
    val replacements = JSONArray()
    val matches = match.suggestedReplacementObjects

    for (replacement in matches.subList(0, Math.min(5, Math.max(0, matches.size - 1)))) {
        val replacementObject = JSONObject()
        replacementObject.put("value", replacement.replacement)
        replacementObject.put("confidence", replacement.confidence)

        replacements.add(replacementObject)
    }

    return replacements
}

private fun cleanSuggestion(s: String): String {
    return s.replace("<suggestion>", "\"").replace("</suggestion>", "\"")
}
