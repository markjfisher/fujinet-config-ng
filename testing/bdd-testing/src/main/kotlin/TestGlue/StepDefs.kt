package TestGlue

import cucumber.api.java.en.Given
import java.io.FileInputStream
import java.nio.file.Paths
import kotlin.io.path.createDirectories
import kotlin.io.path.readLines
import kotlin.io.path.writeText

// This class defines all the cucumber steps that can be included in Feature files.

class StepDefs {
    @Throws(Exception::class)
    @Given("^I load xex \"([^\"]*)\"$")
    fun `i load xex`(file: String) {
        val cwd = Paths.get(".")
        val theFile = cwd.resolve(file)
        val inFile = FileInputStream(theFile.toFile())

        // first 6 bytes:
        // 00-01: $ff $ff
        // 02-03: Load Address (lo, high) start
        // 04-05: Load Address (lo, high) end

        // final 6 bytes
        // 00-01: e0 02 = $02e0
        // 02-03: e1 02 = $02e1 (2 bytes)
        // 00-01: run address

        inFile.readNBytes(2) // ignore marker bytes
        val loadAddressArray = inFile.readNBytes(2)
        val endAddressArray = inFile.readNBytes(2)
        val loadAddress = loadAddressArray[0].toUByte().toInt() + 256 * loadAddressArray[1].toUByte().toInt()
        val endAddress = endAddressArray[0].toUByte().toInt() + 256 * endAddressArray[1].toUByte().toInt()
        val len = endAddress - loadAddress + 1
        val data = inFile.readNBytes(len)
        inFile.readNBytes(4)  // ignore 4 bytes
        val startAddressArray = inFile.readNBytes(2)
        val startAddress = startAddressArray[0].toUByte().toInt() + 256 * startAddressArray[1].toUByte().toInt()

        val machine = Glue.getMachine()
        data.forEachIndexed { i, b ->
            machine.bus.write(startAddress + i, b.toUByte().toInt())
        }
        inFile.close()
    }

    @Given("^I create directory \"([^\"]*)\"\$")
    @Throws(Exception::class)
    fun `i create directory`(dir: String) {
        val cwd = Paths.get(".")
        val newDir = cwd.resolve(dir)
        newDir.createDirectories()
    }

    @Given("^I convert mads-labels file \"([^\"]*)\" to acme labels file \"([^\"]*)\"\$")
    @Throws(Exception::class)
    fun `i convert mads labels to acme file`(madsLabs: String, acmeLabs: String) {
        val cwd = Paths.get(".")
        val madsFile = cwd.resolve(madsLabs)

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

        val lines = madsFile.readLines()
        val outputString = lines.fold("") { s, line ->
            val parts = line.split("\\s+".toRegex())
            if (parts[0] == "00") s + "${parts[2].lowercase()} = ${parts[1].toInt(16)}\n" else s
        }
        val acmeFile = cwd.resolve(acmeLabs)
        acmeFile.writeText(outputString)
    }
}