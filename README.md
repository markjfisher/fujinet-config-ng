# fujinet-config-ng

FujiNet config in asm.

## General information

The application has the concept of modules. These control what data needs to be shown on the screen.

Modules control the next module to load, the first one being the "init" module, which typically connects
to the network, and then passes control to the `hosts` module, to display the list of hosts configured.

Pressing arrow keys typically moves between modules, via the keyboard handlers.

### Keyboard Handlers

More stuff here about common keyboard input during modules, and module specific code. Module keyboard handler
called first, then the common code checks if key not been processed yet.

### Editing fields

Info about `fn_edit` which is device agnostic edit code for changing values in application, e.g. editing
host values.

## Building

Use make. Specify the targets as required (default = atari.full)

```shell
$ make TARGETS=atari.full,apple2 clean all
```

See Variants information below for how to build different subtargets for a platform, if required.

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
See [atari fn_data.inc](src/atari/common/inc/fn_data.inc) for an example.

## COMMON code

The `common` subdir contains device agnostic code. It contains the core FujiNet IO routines.

## Variants

It is also possible to build variants of the application that share common code without having to duplicate source.

See atari.full for an example.

In the target specific directory the following is included by any variant of the target, e.g. for atari.full:

- src/common
- src/atari/common/
- src/atari/full/

If no variant is specified, the additional variant directory will not be included.
