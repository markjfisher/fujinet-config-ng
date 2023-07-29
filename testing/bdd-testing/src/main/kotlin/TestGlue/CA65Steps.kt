package TestGlue

import cucumber.api.Scenario
import cucumber.api.java.Before
import cucumber.api.java.en.Given
import cucumber.runtime.model.CucumberScenario
import java.nio.file.Files
import java.nio.file.Paths
import kotlin.io.path.absolutePathString
import kotlin.io.path.readLines
import kotlin.io.path.writeText

class CA65Steps {
    private val compileFiles: MutableList<String> = mutableListOf()
    private var target: String = ""
    private var workDir: String = ""
    private var config: String = ""
    private var stubIndex: Int = 0

    @Before
    fun beforeHook(s: Scenario) {
        ca65Glue = this
        scenario = s
    }

    /*
    Example input

al 000082 .__ZP_START__
al 003086 ._siov
al 003007 .io_init
al 00302E .setup_screen
al 003000 .start

     */

    @Given("^I convert vice-labels file \"([^\"]*)\" to acme labels file \"([^\"]*)\"$")
    @Throws(Exception::class)
    fun `i convert vice-labels to acme file`(viceLabs: String, acmeLabs: String) {
        val cwd = Paths.get(".")
        val viceFile = cwd.resolve(viceLabs)

        val lines = viceFile.readLines()
        val outputString = lines.fold("") { s, line ->
            val parts = line.split("\\s+".toRegex())
            // There's a bug currently in Glue.java that RHS must be trimmed
            if (parts[0] == "al") {
                s + "${parts[2].lowercase().substring(1)} =0x${parts[1].substring(2)}\n"
            } else {
                s
            }
        }
        val acmeFile = cwd.resolve(acmeLabs)
        acmeFile.writeText(outputString)
    }

    // When I create stub atari application for "io_test" in "build/tests" compiling <list>
    @Given("^I create stub (.*) application for \"([^\"]*)\" in \"([^\"]*)\" compiling$")
    @Throws(Exception::class)
    fun `i create stub application for`(target: String, appName: String, workDir: String, filesToCompile: String) {
        val glue = Glue.getGlue()
        filesToCompile.lines().forEach { f ->
            // cl65 -t atari -c --create-dep build/tests/$1.d -l build/tests/$1.lst -o build/tests/$1.o $2
            glue.i_run_the_command_line("cl65 -t $target -c --create-dep $workDir/${appName}.d -l $workDir/${appName}.lst -o $workDir/${appName}.o ${f.trim()}")
        }
        // cl65 -t atari -vm --mapfile build/tests/$1.map -l build/tests/$1.lst -Ln build/tests/$1.lbl -o build/tests/$1.com -C ../../src/atari/atari.cfg $3 build/tests/$1.o
        glue.i_run_the_command_line("")
    }

    @Given("^I start compiling for (.*) in \"([^\"]*)\" with config \"([^\"]*)\"$")
    @Throws(Exception::class)
    fun `i start compiling for target T in W with config C`(t: String, w: String, c: String) {
        target = t
        compileFiles.clear()
        workDir = w
        config = c
    }

    @Given("^I add file for compiling \"([^\"]*)\"$")
    @Throws(Exception::class)
    fun `i add file for compiling`(fileToCompile: String) {
        compileFiles.add(fileToCompile.trim())
    }

    @Given("^I create and load application$")
    @Throws(Exception::class)
    fun `i create and load application`() {
        // Test is required to specify a _main method to call.
        val stubApp = """
                ; setup basic crt0 code for testing
                    .export _init
                    .import _main
                    
                    .import __MAIN_START__, __MAIN_SIZE__
                    .include "zeropage.inc"
    
                _init:
                    ; setup stack pointer
                    ldx #${"$"}ff
                    txs
                    cld
                    
                    ; software stack starts on top of main
                    lda #<(__MAIN_START__ + __MAIN_SIZE__)
                    sta sp
                    lda #>(__MAIN_START__ + __MAIN_SIZE__)
                    sta sp+1
                    
                    jsr _main
                    brk
    
            """.trimIndent()
        createAndLoadApplication(stubApp)
    }

    @Given("^I create and load simple application$")
    @Throws(Exception::class)
    fun `i create and load simple application`() {
        val stubApp = """
                ; just a simple start, test will call directly to target function
                    .export start
                .proc start
                    rts
                .endproc
            """.trimIndent()
        createAndLoadApplication(stubApp)
    }

    private fun createAndLoadApplication(stubApp: String) {
        val cwd = Paths.get(".")
        val wd = cwd.resolve(workDir)
        val main = Files.createFile(wd.resolve("main.s"))
        main.writeText(stubApp)

        // compile each file
        val glue = Glue.getGlue()
        (compileFiles + "$workDir/main.s").forEach { f ->
            val justName = f.substringAfterLast('/').substringBeforeLast('.')
            val cmd = "cl65 -t $target -c --create-dep $workDir/${justName}.d -l $workDir/${justName}.lst -o $workDir/${justName}.o $f"
            println("running cl65 for $f with cmd: >$cmd<")
            glue.i_run_the_command_line(cmd)
        }
        // create the app
        var mainCmd = "cl65 -t $target -vm --mapfile $workDir/main.map -l $workDir/main.lst -Ln $workDir/main.lbl -o $workDir/main.xex -C $config $workDir/main.o "
        mainCmd += compileFiles.joinToString(" ") { f ->
            val justName = f.substringAfterLast('/').substringBeforeLast('.')
            "$workDir/${justName}.o"
        }
        println("running cl65 for main with cmd: >$mainCmd<")
        glue.i_run_the_command_line(mainCmd)

        val xexSteps = XEXSteps.xexSteps
        xexSteps.`i load xex`("$workDir/main.xex")
        `i convert vice-labels to acme file`("$workDir/main.lbl", "$workDir/main.al")
        glue.i_load_labels("$workDir/main.al")
    }

    @Given("^I stub locations for imports in \"([^\"]*)\" except for \"([^\"]*)\"$")
    @Throws(Exception::class)
    fun `i stub locations for imports except for`(f1: String, exceptionName: String) {
        createStubSource(f1, exceptionName)
    }

    @Given("^I stub locations for imports in \"([^\"]*)\"$")
    @Throws(Exception::class)
    fun `i stub locations for imports`(f1: String) {
        createStubSource(f1)
    }

    private fun createStubSource(f1: String, exceptionName: String = "") {
        val cwd = Paths.get(".")
        val wd = cwd.resolve(workDir)
        val fileWithExports = cwd.resolve(f1)
        val importLines = fileWithExports.readLines().filter { it.trim().startsWith(".import ") }
        val importNames = importLines.joinToString(",") { it.replace(".import", "").replace(" ", "") }.split(",")
        val withoutException = importNames.filterNot { it == exceptionName.trim() }

        val stubHeader = """
            ; stub-${stubIndex} for $f1
                .export ${withoutException.joinToString(", ")}
            
        """.trimIndent()

        val exportSource = withoutException.fold(stubHeader) { full, name ->
            full + "${name}: .res 2\n"
        }

        val exportFile = wd.resolve("stubs-${stubIndex}.s")
        exportFile.writeText(exportSource)
        compileFiles.add("$workDir/stubs-${stubIndex}.s")
        stubIndex++
    }


    companion object {
        lateinit var ca65Glue: CA65Steps
        lateinit var scenario: Scenario
    }
}