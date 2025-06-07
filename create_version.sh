#!/bin/bash

VERSION=1.1.0

echo "${VERSION} ($(git rev-parse --short HEAD))" > src/version.txt
