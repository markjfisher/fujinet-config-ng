# Atari specific folder

## Code directories

The code is split into parts so that several versions can be built. e.g. low memory, or ROM versions.

### common

This folder contains code shared by all flavours of atari builds, lite, 16k, etc.

### full

The full, "everything goes" code where memory isn't a concern. Popups etc are here.


## Testing

The build can automatically debug the application through Altirra.

You must set an environment variable of `ALTIRRA_HOME` for it to work.

```shell
$ make -f Makefile.atari test
```
