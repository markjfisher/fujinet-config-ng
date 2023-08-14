# fujinet-config-ng

FujiNet config in asm.

## General information

The application has the concept of modules. These control what data needs to be shown on the screen.

Modules control the next module to load, the first one being the "init" module, which typically connects
to the network, and then passes control to the `hosts` module, to display the list of hosts configured.

Pressing arrow keys typically moves between modules, via the keyboard handlers.

### Keyboard Hanlers

More stuff here about common keyboard input during modules, and module specific code. Module keyboard handler
called first, then the common code checks if key not been processed yet.

### Editing fields

Info about `fn_edit` which is device agnostic edit code for changing values in application, e.g. editing
host values.

## Building

Pick your target platform's appropriate Makefile, e.g

```shell
$ make -f Makefile.atari clean all
```

## Core application

`config.s` is the first code run, and sets up a basic environment, establishing as software stack, finally calling _main.

This defines the `start` function for the linker to find and run.

## Testing

Testing is done with BDD features. See [Testing README](testing/bdd-testing/README.md)

## Platform Specific Information

Every platform needs to define the following procedures:

### dev_init.s

This is called by the "init" module (first one to load when application runs), and is where
the device specific initialisation of screen, any memory that needs initialising etc.

### main.s

This defines _main. Depending on your setup, you will probably have this called from `start`.

### cfg/your-platform.cfg

Define your own cc65 linker config anywhere on your device specific path.

### INCLUDE files you must implement

- inc/fn_data.inc

This defines various values that IO and keyboard routines need to work on a particular device.
See [atari fn_data.inc](src/atari/inc/fn_data.inc) for an example.

## COMMON code

The `common` subdir contains device agnostic code. It contains the core FujiNet IO routines.
