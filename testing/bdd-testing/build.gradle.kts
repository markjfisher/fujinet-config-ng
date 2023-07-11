plugins {
    kotlin("jvm") version "1.8.21"
    application
}

group = "net.fish.bdd6502"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation(files("lib/BDD6502-1.0.9-SNAPSHOT-jar-with-dependencies.jar"))

    testImplementation(kotlin("test"))
}

kotlin {
    jvmToolchain(11)
}

tasks {
    test {
        useJUnitPlatform()
    }

    register("runFeatures", JavaExec::class) {
        mainClass.set("bdd6502.RunFeatureTests")
        classpath = sourceSets["main"].runtimeClasspath
        jvmArgs = listOf(
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang.reflect=ALL-UNNAMED",
            "--add-opens", "java.base/java.text=ALL-UNNAMED",
            "--add-opens", "java.desktop/java.awt.font=ALL-UNNAMED",
        )
    }

    register("runFeaturesWithTrace", JavaExec::class) {
        mainClass.set("bdd6502.RunFeatureTests")
        classpath = sourceSets["main"].runtimeClasspath
        jvmArgs = listOf(
            "-Dbdd6502.trace=true",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang.reflect=ALL-UNNAMED",
            "--add-opens", "java.base/java.text=ALL-UNNAMED",
            "--add-opens", "java.desktop/java.awt.font=ALL-UNNAMED",
        )
    }
}

application {
    // Run the main server, then connect to the webpage to run tests etc.
    mainClass.set("MainKt")
    applicationDefaultJvmArgs = listOf(
        "-Dbdd6502.trace=true",
        "-Dcom.replicanet.cukesplus.server.featureEditor",
        "-Dcom.replicanet.ACEServer.debug.requests=",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang.reflect=ALL-UNNAMED",
        "--add-opens", "java.base/java.text=ALL-UNNAMED",
        "--add-opens", "java.desktop/java.awt.font=ALL-UNNAMED",
    )
}