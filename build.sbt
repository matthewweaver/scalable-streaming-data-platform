ThisBuild / scalaVersion := "2.12.7"

val flinkVersion = "1.7.2"
lazy val hello = (project in file("."))
  .settings(
    name := "KafkaConsumer",
    libraryDependencies += "org.apache.flink" %% "flink-scala" % flinkVersion,
    libraryDependencies += "org.apache.flink" %% "flink-streaming-scala" % flinkVersion,
    libraryDependencies += "org.apache.flink" %% "flink-connector-kafka" % flinkVersion,
    test in assembly := {},
    mainClass in assembly := Some("flink.KafkaConsumer"),
    assemblyJarName in assembly := "flinkconsumer.jar"
  )