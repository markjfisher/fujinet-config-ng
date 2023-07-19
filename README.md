# fujinet-config-ng

FujiNet config in asm.

## General information

The application has the concept of modules. These control what data needs to be shown on the screen.
Probably other stuff I have to work out yet.

## Building

Pick your target platform's appropriate Makefile, e.g

```shell
$ make -f Makefile.atari clean all
```

## Testing

Testing is done with BDD features. See [Testing README](testing/bdd-testing/README.md)

## Platform Specific Information

Every platform needs to define the following procedures:
- `setup_screen` : used to initialise the screen, e.g. display list, vbi for atari
- `copy_to_screen` : used to copy the current module's data into the screen


### Atari

The build can automatically debug the application through Altirra.

```shell
$ make -f Makefile.atari clean all debug
```
