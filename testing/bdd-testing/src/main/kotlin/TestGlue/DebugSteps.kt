package TestGlue

import TestGlue.Glue.valueToInt
import cucumber.api.java.en.Given
import org.apache.commons.lang3.CharUtils

class DebugSteps {
    @Throws(Exception::class)
    @Given("^I print memory from (.*) to (.*)$")
    fun `i print memory`(start: String, end: String) {
        val machine = Glue.getMachine()
        var addrStart: Int = valueToInt(start)
        val addrEnd: Int = valueToInt(end)

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
            val theByte: Int = machine.getBus().read(addrStart, false)
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

        println(hexOutput)

    }
}