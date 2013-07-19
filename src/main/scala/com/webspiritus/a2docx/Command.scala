package com.webspiritus.a2docx

import sbt.{CommandSupport, Extracted, Project, RichFile, State}
import sbt.Path.richFile

object Command {
  val name = "a2docx"
  val briefHelp =
    (name + " generate",
     "Creates OpenXML Word documents from asciidoc documents.")
  val detail = ""
  val display = ""
  def a2docx = sbt.Command.args(name, briefHelp, detail, display) {
    case (state, "generate"::rest) => {
      implicit val s = state
      info("Generating...")

      val extracted: Extracted = Project.extract(state)
      val target = extracted.get(sbt.Keys.target) / name
      val source = extracted.get(sbt.Keys.sourceDirectory) / "asciidoc"
      info("name = " + extracted.get(sbt.Keys.name))
      info("target = " + target.toString())
      info("sourceDirectory = " + source.toString)
      Generator(source, target)(CommandSupport.logger(state))
      state
    }
    case (state, args)  => {
      implicit val s = state
      info(briefHelp._1)
      state
    }
  }
  private def info(message: String)(implicit state: State): Unit = CommandSupport.logger(state).info(message)
}
