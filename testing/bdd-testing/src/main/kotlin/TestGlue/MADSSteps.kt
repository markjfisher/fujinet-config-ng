package TestGlue

import cucumber.api.java.en.Given
import java.nio.file.Paths
import kotlin.io.path.readLines
import kotlin.io.path.writeText

// MADS label file has format:
// -----
// mads 2.1.7
// Label table:
// 00 1234 NAME

// the first number is 00 for final addresses, we only want these.
// Other numbers are 01 for relocatable, FFF8 for external

// The output format is:
// NAME = 16384
// BAR = 1024


class MADSSteps {
    @Given("^I convert mads-labels file \"([^\"]*)\" to acme labels file \"([^\"]*)\"$")
    @Throws(Exception::class)
    fun `i convert mads labels to acme file`(madsLabs: String, acmeLabs: String) {
        val cwd = Paths.get(".")
        val madsFile = cwd.resolve(madsLabs)

        val lines = madsFile.readLines()
        val outputString = lines.fold("") { s, line ->
            val parts = line.split("\\s+".toRegex())
            // There's a bug currently in Glue.java that RHS must be trimmed
            if (parts[0] == "00") s + "${parts[2].lowercase()} =0x${parts[1]}\n" else s
        }
        val acmeFile = cwd.resolve(acmeLabs)
        acmeFile.writeText(outputString)
    }
}