package TestGlue

import cucumber.api.java.en.Given

class DebugSteps {

    @Throws(Exception::class)
    @Given("^I print memory from (.*) to (.*)$")
    fun `i print memory`(start: String, end: String) {
        println(MemorySteps.memoryHex(start, end, Glue.getMachine()))
    }
}