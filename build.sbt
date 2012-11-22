sbtPlugin := true

organization := "com.webspiritus"

name := "asciidoc2docx"

version := "0.1-SNAPSHOT"

scalacOptions ++= Seq("-deprecation", "-unchecked")

libraryDependencies ++= Seq("commons-io" % "commons-io" % "2.4")
