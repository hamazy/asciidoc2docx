package com.webspiritus.a2docx

import sbt.{Keys, Project}

object Plugin extends sbt.Plugin {

  override lazy val settings = Seq(
    Keys.commands += Command.a2docx
  )
}
