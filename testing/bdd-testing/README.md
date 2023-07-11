# BDD testing 6502

This subdirectory contains the code for BDD testing ASM code.

It is a kotlin project using gradle to build. Everything can be run from the command line, however if you
wish to extend tests and add new Steps (the main part of features) you will be better served with an IDE.
I'm using IntelliJ, and there are run configurations setup for using in IntelliJ.

## Running tests

Open a terminal and cd into the bdd-testing directory, and run following:

```shell
./gradlew runFeatures
```

You can also enable 6502 tracing in the output (i.e. full dump of everything the 6502 is doing) by running:

```shell
./gradlew runFeaturesWithTrace
```

Windows users should be able to run `.\gradlew.bat` instead of `./gradlew` in the above.

## Interactive Development and testing

This is the hot stuff.

Running the following will start up a server for interactive BDD development.

```shell
./gradlew run
```

The service will start a listener at port 8001. Navigate to the following page:

- http://localhost:8001/ace-builds-master/demo/autocompletion.html

This will present you with a CukesPlus test page, with the features listed down the left hand side.

To run one, click on it, and then click the "Run file" button. You can view results on the page, with
additional logs in the terminal where you started the server.

Making changes to the feature can be done in the UI. It has introspection on the steps too, for instance
type "And I run <ctrl enter>" and it will pop up all the available steps that will complete the step.

Press ctrl-s to save it back to the server.

If you need to create new Steps, do so in the `TestGlue` package, e.g. [StepDefs](src/main/kotlin/TestGlue/StepDefs.kt).
This is the code that cucumber (the BDD testing framework) will use to bridge the gap between features
and its simple english statements, and the things that actually run when the test is invoked.

After making appropriate new Steps, restart the service, and they will be available in the webclient UI to
use.

## How it works

This project uses the [BDD6502](https://github.com/martinpiper/BDD6502) framework.

Tests (or features) should go into [features](/features) folder.

## Example feature

There is a test feature here: [features/MachineState.feature](features/MachineState.feature) which you can use to
understand the basics of features.

Typically there's some setup of creating a 6502 instance, compiling some code, then allowing the 6502 emulator to
run it, and test the state.

A lot more examples can be found at https://github.com/martinpiper/BDD6502/tree/master/features

Note the original project is geared towards ACME assembler and C64 dev, so some things will not immediately work here.

## Future plans

- Integration with Altirra maybe?
- Examples of working with the ASM code properly, not copying small bits of code into tests.
