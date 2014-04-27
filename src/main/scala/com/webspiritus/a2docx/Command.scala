package com.webspiritus.a2docx

import sbt.{ Extracted, Project, RichFile, State }
import sbt.Path.richFile

object Command {
  val name = "a2docx"
  val briefHelp =
    (name + " generate",
      "Creates OpenXML Word documents from asciidoc documents.")
  val detail = ""
  val display = ""
  def a2docx = sbt.Command.args(name, briefHelp, detail, display) {
    case (state, "generate" :: _) => {
      state.log.info("Generating...")
      val extracted: Extracted = Project.extract(state)
      val target = extracted.get(sbt.Keys.target) / name
      val source = extracted.get(sbt.Keys.sourceDirectory) / "main/asciidoc"
      state.log.debug("name = " + extracted.get(sbt.Keys.name))
      state.log.debug("target = " + target.toString())
      state.log.debug("sourceDirectory = " + source.toString)
      Generator(source, target, state)
      state
    }
    case (state, args) => state
  }
}
