package TestGlue

import cucumber.api.java.en.Given
import java.io.FileInputStream
import java.nio.file.Paths

class XEXSteps {
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

}