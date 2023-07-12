package TestGlue

import com.loomcom.symon.machines.Machine
import cucumber.api.java.en.Given
import xex.ABFile
import xex.DataSection
import java.nio.file.Paths
import kotlin.io.path.absolutePathString
import kotlin.io.path.readBytes

class XEXSteps {
    @Throws(Exception::class)
    @Given("^I load xex \"([^\"]*)\"$")
    fun `i load xex`(file: String) {
        val cwd = Paths.get(".")
        val machine = Glue.getMachine()

        // load all the DataSections of the binary into memory into their respective load locations
        val abFile = ABFile(cwd.resolve(file).readBytes())
        // abFile.dump()
        copyToMachine(abFile, machine)
        machine.cpu.programCounter = abFile.runAddress
    }

    @Given("^I patch machine from obx file \"([^\"]*)\"\$")
    @Throws(Exception::class)
    fun `i patch machine from obx file`(f: String) {
        val cwd = Paths.get(".")
        val obx = cwd.resolve("${f}.obx")
        val lbl = cwd.resolve("${f}.al")
        val machine = Glue.getMachine()

        // the obx file needs to be xex format, not mads relocatable (FFFE etc)
        val abFile = ABFile(obx.toFile().readBytes())
        copyToMachine(abFile, machine)
        Glue.loadLabels(lbl.absolutePathString())
    }

    private fun copyToMachine(abFile: ABFile, machine: Machine) {
        abFile.sections.filterIsInstance<DataSection>().forEach { ds ->
            ds.data.forEachIndexed { i, b ->
                machine.bus.write(ds.startAddress + i, b.toUByte().toInt())
            }
        }
    }

}