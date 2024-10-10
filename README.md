# fujinet-config-ng

FujiNet config for Atari in asm.

## Building

You need cc65 installed to compile the config-ng, and dir2atr to create ATR images for atari.

If you wish to compress the config-ng binary, you will need the project fujinet-config-loader in a sibling directory to this project.

If you have the `fujinet-config-tools` project in a sibling directory, and with all applications built in it (see its readme) then
any built com files will be add to the ATR when doing a `disk` or `diskz` task.

Typical invocations to build various tasks are:

```shell
# clean up any old build artifacts
$ rm -rf dist obj build

# just the application in dist/config.atari.full.com
$ make clean all

# a non-compressed atr image (see Create ATR below)
$ make clean disk

# a compressed binary atr image (requires fujinet-config-loader as mentioned above)
$ make clean diskz

# Run application using Altirra, see "Running" below
$ export ALTIRRA_HOME=/path/to/your/Altirra.exe
$ make test
```

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

## Running

As a fujinet application, you need to have your emulator available (altirra for atari) and appropriate fujinet-pc
connectivity available (e.g. bridge for atari, and altirra configured to use it).

Then you can issue:

```shell
make test
```

which will run the application in the appropriate emulator. For altirra, you must set `ALTIRRA_HOME` to path of the folder it lives in.

## Create ATR

You can create an ATR with the config application in it.

Additionally, you can use the fujinet-config-loader to display an opening image and compress config to enable faster loading on non-hsio systems.

Examples are given below. In all cases the generated file is "autorun.atr" in the root dir.

For generating config-loader enabled atr images, you must define the path to `fujinet-config-loader` via the `FN_CONFIG_LOADER` build value.
If you have the project as a sibling project to this repository, (i.e. at ../fujinet-config-loader) then it will automatically be found.

```shell
# create simple atr with config and tools
make clean all disk

# use config-loader with default image
make clean all diskz

# use custom banner (you must create your own banners)
make diskz BANNERMODE=E BANNERSIZE=large BANNERNAME=cng BANNERLOAD=32768

# uploading directly to SD card on FujiNet
duck --upload dav://anonymous@fujinet.home/dav/autorun-cng-1.0.0.atr dist/autorun-cng-1.0.0.atr -existing overwrite
```

## Core application

The application startup sequence is:

1. `pre_init` is loaded as segments are loaded for the application

    This does some one time code (e.g. bank detection, font loading, reset handler).
    The memory for this code is overwritten later as it is no longer needed after running once.

2. `_start` runs from crt0.s in cc65

3. `_main` runs from `_start`

Main starts the first `module`, which is Mod::Init (`_mod_init`), the locations of code
corresponding to the modules is in `run_module.s`.

The init module sets up the application state, and loads the wifi settings if possible.
If it is able to, it passes control to the `hosts` module, otherwise it passes control to
the `wifi` module so that a wifi can be picked by the user.

After this, user navigation dictates which module to load.

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
