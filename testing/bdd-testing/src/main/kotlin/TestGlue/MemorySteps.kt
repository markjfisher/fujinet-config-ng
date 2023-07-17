package TestGlue

import com.loomcom.symon.machines.Machine
import cucumber.api.java.en.Given
import org.assertj.core.api.Assertions.assertThat
import kotlin.io.path.absolutePathString
import kotlin.io.path.createTempFile
import kotlin.io.path.deleteIfExists
import kotlin.io.path.writeText

class MemorySteps {
    @Throws(Exception::class)
    @Given("^I fill memory from (.*) to (.*) with (.*)$")
    fun `i fill memory from A to B with`(start: String, end: String, v: String) {
        val startAddress = Glue.valueToInt(start)
        val endAddress = Glue.valueToInt(end)
        val value = Glue.valueToInt(v)
        val count = endAddress - startAddress + 1

        val machine = Glue.getMachine()
        repeat(count) { i ->
            machine.bus.write(startAddress + i, value)
        }
    }
    @Throws(Exception::class)
    @Given("^I hex dump memory for (.*) bytes from property \"([^\"]*)\"$")
    fun `i hex dump memory for n bytes from property`(nBytes: String, propName: String) {
        val startAddress = System.getProperty(propName).toInt()
        val endAddress = startAddress + nBytes.toInt()
        val hex = memoryHex("$startAddress", "$endAddress", Glue.getMachine())
        System.setProperty("test.BDD6502.lastHexDump", hex)
    }

    @Throws(Exception::class)
    @Given("^I hex\\+ dump memory between (.*) and (.+)$")
    fun `i hex dump memory between X and Y improved`(start: String, end: String) {
        val hex = memoryHex(start, end, Glue.getMachine())
        System.setProperty("test.BDD6502.lastHexDump", hex)
        Glue.getGlue().scenario.write(hex)
    }

    @Throws(Exception::class)
    @Given("^I hex\\+ dump ascii between (.*) and (.+)$")
    fun `i hex dump ascii between X and Y improved`(start: String, end: String) {
        val hex = memoryHex(start, end, Glue.getMachine(), false)
        System.setProperty("test.BDD6502.lastHexDump", hex)
        Glue.getGlue().scenario.write(hex)
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

    @Throws(Exception::class)
    @Given("^memory at registers (.*) contains$")
    fun `memory at registers contains`(regs: String, structData: String) {
        assertMemoryMatches(structData, Glue.getMachine(), CpuSteps.regsToAddress(regs))
    }

    @Throws(Exception::class)
    @Given("^memory at ([^\\s]*) contains$")
    fun `memory at contains`(location: String, structData: String) {
        assertMemoryMatches(structData, Glue.getMachine(), Glue.valueToInt(location))
    }

    private fun assertMemoryMatches(structData: String, machine: Machine, address: Int) {
        // each line contains an offset to add after the test, and a string to check at start of current address
        // e.g.
        // 33:ssid here
        // 15:another string

        var mutableAddress = address
        structData.lines().forEach { line ->
            val parts = line.split(":")
            val offset = parts[0].trim().toInt()
            val testString = parts[1].trim()
            val memString = testString.indices.map { i -> internalToChar(machine.cpu.bus.read(mutableAddress + i)) }.joinToString("")
            assertThat(memString).isEqualTo(testString)

            mutableAddress += offset
        }
    }

    @Throws(Exception::class)
    @Given("^I set label (.*) to registers address (.*)$")
    fun `I set label to registers address`(label: String, regs: String) {
        val address = CpuSteps.regsToAddress(regs)
        val tempFile = createTempFile()
        tempFile.writeText("$label =$address")
        Glue.loadLabels(tempFile.absolutePathString())
        tempFile.deleteIfExists()
    }

    @Throws(Exception::class)
    @Given("^I write string \"([^\"]*)\" as ascii to memory address (.*)$")
    fun `i write string as ascii to memory address`(s: String, adr: String) {
        val scenario = Glue.getGlue().scenario
        val address = Glue.valueToInt(adr)
        scenario.write("Writing string \"$s\" to address: 0x${address.toString(16)} as ascii")
        // Should write (at)ascii, not internal, as space is 00, which is null terminator too!
        val machine = Glue.getMachine()
        s.forEachIndexed { i, c ->
            machine.bus.write(address + i, c.code)
        }
        // end with nul (0) char to terminate string
        machine.bus.write(address + s.length, 0)
    }

    @Throws(Exception::class)
    @Given("^I write string \"([^\"]*)\" as internal to memory address (.*)$")
    fun `i write string as internal to memory address`(s: String, adr: String) {
        val scenario = Glue.getGlue().scenario
        val address = Glue.valueToInt(adr)
        scenario.write("Writing string \"$s\" to address: 0x${address.toString(16)} as internal")
        // Should write internal, as space is 00, which is null terminator too!
        val machine = Glue.getMachine()
        s.forEachIndexed { i, c ->
            machine.bus.write(address + i, charToInternal(c))
        }
    }

    companion object {
        fun memoryHex(start: String, end: String, machine: Machine, isInternal: Boolean = true): String {
            var currentAddress: Int = Glue.valueToInt(start)
            val addrEnd: Int = Glue.valueToInt(end)

            var cr = 0
            var hexOutput = ""
            var section = ""
            while (currentAddress < addrEnd) {
                if (cr == 0) {
                    hexOutput += String.format("%2s:", Integer.toHexString(currentAddress).replace(' ', '0'))
                }
                if (cr == 8) {
                    hexOutput += " "
                }
                val v: Int = machine.bus.read(currentAddress, false)
                val hex = String.format("%2s", Integer.toHexString(v)).replace(' ', '0')
                section += if (isInternal) internalToChar(v) else Char(v)
                hexOutput += " $hex"
                cr += 1
                if (cr >= 16) {
                    hexOutput += " : >$section<\n"
                    cr = 0
                    section = ""
                }
                currentAddress++
            }

            if (section.isNotEmpty()) {
                hexOutput += " : >$section<"
            }
            return hexOutput
        }

        fun internalToChar(v: Int): Char {
            return when (v) {
                in 0..63 -> internalToCharMap.getOrDefault(v, '.')
                in 97..122 -> 'a' + v - 97
                else -> '.'
            }
        }

        fun charToInternal(c: Char): Int = charToInternalMap.getOrDefault(c, 0)

        private val internalToCharMap = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_".mapIndexed { i, c -> i to c }.toMap().toMutableMap().let { m ->
            (97 .. 122).forEach { i -> m[i] = Char(i) } // add 'a..z'
            m
        }.toMap()
        private val charToInternalMap = internalToCharMap.entries.associate { (i, c) -> c to i }
        private val defaultCode = charToInternalMap['.']!!
    }
}