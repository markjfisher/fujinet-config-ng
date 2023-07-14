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

    @Throws(Exception::class)
    @Given("^I write word at (.*) with hex (.*)$")
    fun `i write word at with hex`(mem: String, hex: String) {
        if (hex.length > 4 || hex.isEmpty()) throw Exception("hex specified cannot be written to word: >$hex<")

        val address = Glue.valueToInt(mem)

        var nHex = hex // normalise to 2 or 4 bytes
        if (hex.length == 1 || hex.length == 3) nHex = "0${hex}"
        val hi = if (nHex.length == 2) 0 else nHex.substring(0, 2).toInt(16)
        val loIndex = if (nHex.length == 4) 2 else 0
        val lo = nHex.substring(loIndex, loIndex + 2).toInt(16)

        println("MemorySteps::I write word at with hex: mem: $mem, hex: $hex, address: ${address.toString(16)}, lo: ${lo.toString(16)}, hi: ${hi.toString(16)}")
        val machine = Glue.getMachine()
        machine.bus.write(address, lo)
        machine.bus.write(address+1, hi)
    }

}