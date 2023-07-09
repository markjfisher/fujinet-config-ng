# fujinet-config-ng

FujiNet config in asm.

## General information

The application has the concept of modules. These control what data needs to be shown on the screen.
Probably other stuff I have to work out yet.

## Building

Pick your target platform's appropriate Makefile, e.g

```shell
$ make -f Makefile.atari clean
$ make -f Makefile.atari
```

There is a default Makefile that will build a basic non-platform specific version of
the application, "main.com". This doesn't currently do a lot, as it has no screen setup or
drawing implementation, but is enough to compile the common code into a default application.

## Platform Specific Information

Every platform needs to define the following procedures:
- `setup_screen` : used to initialise the screen, e.g. display list, vbi for atari
- `copy_to_screen` : used to copy the current module's data into the screen



### Atari

The build can automatically debug the application through Altirra.

```shell
$ make -f Makefile.atari clean && make -f Makefile.atari && make -f Makefile.atari debug
```
