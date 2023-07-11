package TestGlue

import cucumber.api.java.en.Given
import java.nio.file.Paths
import kotlin.io.path.createDirectories

class FileSteps {
    @Given("^I create directory \"([^\"]*)\"\$")
    @Throws(Exception::class)
    fun `i create directory`(dir: String) {
        val cwd = Paths.get(".")
        val newDir = cwd.resolve(dir)
        newDir.createDirectories()
    }
}