package com.webspiritus.a2docx

import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.FilenameFilter
import java.io.InputStream
import java.io.OutputStream
import java.io.OutputStreamWriter
import java.io.StringWriter
import java.lang.Runtime
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream
import javax.xml.parsers.SAXParserFactory
import javax.xml.transform.Source
import javax.xml.transform.TransformerFactory
import javax.xml.transform.sax.SAXSource
import javax.xml.transform.stream.StreamResult
import javax.xml.transform.stream.StreamSource
import org.apache.commons.io.FileUtils
import org.xml.sax.InputSource
import sbt.Logger
import sbt.RichFile
import sbt.Path.richFile
import scala.xml.XML

object Generator {
  implicit def file2AsciiDoc(file: File): AsciiDocFile = new AsciiDocFile(file)
  def apply(sourceDirectory: File, targetDirectory: File)(implicit logger: Logger): Unit = {
    if (!sourceDirectory.exists) return;
    if (!targetDirectory.isDirectory) {
      targetDirectory.mkdir()
    }
    sourceDirectory.listFiles().filter(_.getName.trim.endsWith(".asciidoc")).foreach { file => 
      new Generator(file, targetDirectory).generate
    }
  }
}

class Generator(sourceFile: AsciiDocFile, targetParentDirectry: File)(implicit logger: Logger) {
  private val targetDirectory: File = {
    val targetDirectory = targetParentDirectry / sourceFile.file.base
    if (!targetDirectory.exists) targetDirectory.mkdir
    targetDirectory
  }
  import scala.actors.Actor._
  def generate(implicit logger: Logger): Unit = {

    if (!generateDocBook(sourceFile, targetDirectory)) return
    val docbookFile = sourceFile.targetDocBookFile(targetDirectory)
    val docxFile = new DocxFile(targetDirectory, sourceFile.file.base)
    generateStyles(docbookFile, docxFile)
    generateNumbering(docbookFile, docxFile)
    generateFooter1(docbookFile, docxFile)
    generateHeader1(docbookFile, docxFile)
    generateDocumentRelationships(docbookFile, docxFile)
    generateContentTypes(docbookFile, docxFile)
    generateDocument(docbookFile, docxFile)
    generateRelationships(docbookFile, docxFile)

    val images = listImages(sourceFile, docbookFile, docxFile)
    images.foreach(f => FileUtils.copyFileToDirectory(f, docxFile.mediaDirectory.raw))

    writeIcons(docxFile)

    docxFile.writeZipFile()
  }
  /* foo.asciidoc => foo.xml in DocBook format */
  private def generateDocBook(sourceFile: AsciiDocFile, targetDirectory: File)(implicit logger: Logger): Boolean = {
    val runtime = Runtime.getRuntime
    val process = runtime.exec(Array("a2x", "-v", "-f", "docbook", "-D", targetDirectory.getAbsolutePath(), sourceFile.absolutePath))

    def writeLines(inputStream: InputStream) =
      scala.io.Source.fromInputStream(inputStream).getLines().foreach(line => logger.info(line))

    actor(writeLines(process.getErrorStream))
    actor(writeLines(process.getInputStream))

    process.waitFor() match {
      case 0 => true
      case _ => false
    }
  }
  val transformer = Transformer
  def generateStyles(docbookFile: File, targetFile: DocxFile)(implicit logger: Logger) = 
    transformer.transform(docbookFile, targetFile.styles, "styles", targetFile.baseDirectory)

  def generateNumbering(docbookFile: File, targetFile: DocxFile)(implicit logger: Logger) =
    transformer.transform(docbookFile, targetFile.numbering, "numbering", targetFile.baseDirectory)

  def generateFooter1(docbookFile: File, targetFile: DocxFile)(implicit logger: Logger) =
    transformer.transform(docbookFile, targetFile.footer1, "footer1", targetFile.baseDirectory)

  def generateHeader1(docbookFile: File, targetFile: DocxFile)(implicit logger: Logger) =
    transformer.transform(docbookFile, targetFile.header1, "header1", targetFile.baseDirectory)

  def generateDocumentRelationships(docbookFile: File, targetFile: DocxFile)(implicit logger: Logger) =
    transformer.transform(docbookFile, targetFile.documentRelationships, "document-rels", targetFile.baseDirectory)

  def generateContentTypes(docbookFile: File, targetFile: DocxFile)(implicit logger: Logger) =
    transformer.transform(docbookFile, targetFile.contentTypes, "content-types", targetFile.baseDirectory)

  def generateDocument(docbookFile: File, targetFile: DocxFile)(implicit logger: Logger) =
    transformer.transform(docbookFile, targetFile.document, "document", targetFile.baseDirectory)

  def generateRelationships(docbookFile: File, targetFile: DocxFile)(implicit logger: Logger) =
    transformer.transform(docbookFile, targetFile.relationships, "root-rels", targetFile.baseDirectory)

  def listImages(sourceFile: AsciiDocFile, docbookFile: File, targetFile: DocxFile): List[File] = {
    val buffer = new StringWriter
    transformer.transform(docbookFile, new StreamResult(buffer), "list-images", targetFile.mediaDirectory.raw)
    val xmlDoc = XML.loadString(buffer.toString)
    (xmlDoc \ "image").toList map (_.text) map (new File(sourceFile.file.asFile.getParentFile, _))
  }

  private def writeIcons(targetFile: DocxFile) = {
    List("caution.png", "important.png", "note.png", "tip.png", "warning.png") map { filename =>
      (getClass.getResourceAsStream(filename), new File(targetFile.mediaDirectory.raw, filename))
    } foreach { e=> FileUtils.copyInputStreamToFile(e._1, e._2) }
  }
}

object Transformer {
  val transformer = {
    val factory = TransformerFactory.newInstance()
    val xslt = new StreamSource(getClass.getResourceAsStream("asciidoc2docx.xsl"))
    val transformer = factory.newTransformer(xslt)
    transformer
  }
  val reader = {
    val factory = SAXParserFactory.newInstance()
    factory.setNamespaceAware(true)
    factory.setValidating(false)

    // avoid internet access for validating a document against its schema definition.
    factory.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false)

    factory.newSAXParser.getXMLReader()
  }
  def transform(source: File, result: File, mode: String, targetBaseDirectory: File): Unit =
    transform(source, new StreamResult(result), mode, targetBaseDirectory)

  def transform(source: File, result: StreamResult, mode: String, targetBaseDirectory: File): Unit = {
    transformer.clearParameters()
    transformer.setParameter("what-to-gen", mode)
    transformer.setParameter("target-base", targetBaseDirectory.getPath())
    transformer.transform(new SAXSource(reader, new InputSource(new FileInputStream(source))), result)
  }
}

class AsciiDocFile(val file: RichFile) {
  val absolutePath = file.absolutePath
  def targetDocBookFile(targetDirectory: File): File = {
    new File(targetDirectory, file.base + ".xml")
  }
}

case class Directory(parent: File, name: String) {
  import scala.collection.JavaConverters._
  val raw = new File(parent, name)
  if (!raw.exists()) raw.mkdir
  def /(filename: String) = raw / filename
  def listFiles(): List[File] =
    FileUtils.listFiles(raw, null, true).asScala.toList
}
class DocxFile(val baseDirectory: File, val base: String) {
  lazy val wordDirectory = Directory(baseDirectory, "word")
  lazy val relsDirectory = Directory(baseDirectory, "_rels")
  lazy val wordRelsDirectory = Directory(wordDirectory, "_rels")
  lazy val mediaDirectory = Directory(baseDirectory, "media")
  implicit def directory2file(directory: Directory): File = directory.raw

  val contentTypes = baseDirectory / "[Content_Types].xml"
  val relationships = relsDirectory / ".rels"
  val document = wordDirectory /  "document.xml"
  val styles = wordDirectory / "styles.xml"
  val numbering = wordDirectory / "numbering.xml"
  val header1 = wordDirectory / "header1.xml"
  val footer1 = wordDirectory / "footer1.xml"
  val documentRelationships = wordRelsDirectory / "document.xml.rels"
  def writeZipFile() = {
    val zipStream = new ZipOutputStream(new FileOutputStream(new File(baseDirectory.getParent(), base + ".docx")))
    val entries = List(document, contentTypes, relationships, styles,
		       numbering, header1, footer1, documentRelationships) ++ mediaDirectory.listFiles()
    def addEntryToZipStream(entry: File) = entry.relativeTo(baseDirectory) map { relative =>
      zipStream.putNextEntry(new ZipEntry(relative.getPath()))
      FileUtils.copyFile(entry, zipStream)
      zipStream.closeEntry()
    }
    entries.foreach(addEntryToZipStream)
    zipStream.close()
  }
}
