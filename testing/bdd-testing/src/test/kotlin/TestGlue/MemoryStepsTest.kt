package testglue

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class MemoryStepsTest {
    @Test
    fun `list of chars can be converted to string`() {
        val chars = listOf('h', 'e', 'l', 'l', 'o')
        assertThat(chars.joinToString("")).isEqualTo("hello")
    }
}