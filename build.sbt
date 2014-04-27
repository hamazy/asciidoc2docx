sbtPlugin := true

organization := "com.webspiritus"

name := "asciidoc2docx"

version := "0.1-SNAPSHOT"

scalacOptions ++= Seq("-deprecation", "-unchecked", "-feature")

libraryDependencies ++= Seq("commons-io" % "commons-io" % "2.4")
