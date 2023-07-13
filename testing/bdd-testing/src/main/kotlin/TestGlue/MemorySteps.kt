package TestGlue

import com.loomcom.symon.machines.Machine
import cucumber.api.java.en.Given
import org.apache.commons.lang3.CharUtils

class MemorySteps {
    @Throws(Exception::class)
    @Given("^I hex dump memory for (.*) bytes from property \"([^\"]*)\"\$")
    fun `i hex dump for n bytes from property`(nBytes: String, propName: String) {
        val startAddress = System.getProperty(propName).toInt()
        val endAddress = startAddress + nBytes.toInt()
        val hex = memoryHex("$startAddress", "$endAddress", Glue.getMachine())
        System.setProperty("test.BDD6502.lastHexDump", hex)
    }

    companion object {
        fun memoryHex(start: String, end: String, machine: Machine): String {
            var addrStart: Int = Glue.valueToInt(start)
            val addrEnd: Int = Glue.valueToInt(end)

            var cr = 0
            var hexOutput = ""
            var section = ""
            while (addrStart < addrEnd) {
                if (cr == 0) {
                    hexOutput += String.format("%2s:", Integer.toHexString(addrStart).replace(' ', '0'))
                }
                if (cr == 8) {
                    hexOutput += " "
                }
                val theByte: Int = machine.bus.read(addrStart, false)
                val hex = String.format("%2s", Integer.toHexString(theByte)).replace(' ', '0')
                section += if (CharUtils.isAsciiPrintable(theByte.toChar())) {
                    theByte.toChar()
                } else {
                    '.'
                }
                hexOutput += " $hex"
                cr += 1
                if (cr >= 16) {
                    hexOutput += " : $section"
                    hexOutput += "\n"
                    cr = 0
                    section = ""
                }
                addrStart += 1
            }

            if (section.isNotEmpty()) {
                hexOutput += " : $section"
            }
            return hexOutput
        }
    }

}