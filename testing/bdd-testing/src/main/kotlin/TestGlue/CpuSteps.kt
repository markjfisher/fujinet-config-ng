package TestGlue

import cucumber.api.java.en.Given
import org.hamcrest.MatcherAssert.assertThat
import org.hamcrest.Matchers.*


class CpuSteps {
    @Throws(Exception::class)
    @Given("^I expect register state (.*)$")
    fun `i expect register state`(statusCmd: String) {
        // allow register checking with an input of the format:
        // Z:1       # Z flag is on (0 for off)
        // Combinations separated by commas:
        // N:0,Z:0   # N,Z flags both off
        // This allows us to test single or multiple status flags directly instead of the "include"/"exclude" steps

        val machine = Glue.getMachine()
        val flagToOnOff = statusCmd.split(",").fold(mutableMapOf<Char, Boolean>()) { m, cmd ->
            // convert FLAG:0/1 into map entry
            // Flags are: N,C,Z,I,D,V
            val parts = cmd.split(":")
            // only use first character of the Left side, and only match 0 for false, everything else is true.
            m[parts[0][0]] = parts[1] != "0"
            m
        }
        println("Testing status flags against: $flagToOnOff")

        flagToOnOff.forEach { (r, onOff) ->
            when(r) {
                'N' -> assertThat(machine.cpu.negativeFlag,    `is`(equalTo(onOff)))
                'C' -> assertThat(machine.cpu.carryFlag,       `is`(equalTo(onOff)))
                'Z' -> assertThat(machine.cpu.zeroFlag,        `is`(equalTo(onOff)))
                'I' -> assertThat(machine.cpu.irqDisableFlag,  `is`(equalTo(onOff)))
                'D' -> assertThat(machine.cpu.decimalModeFlag, `is`(equalTo(onOff)))
                'V' -> assertThat(machine.cpu.overflowFlag,    `is`(equalTo(onOff)))
                else -> throw Exception("Unknown register: $r in statusCmd: $statusCmd")
            }
        }
    }
}