#!/bin/bash

VERSION=1.1.2

echo "${VERSION} ($(git rev-parse --short HEAD))" > src/version.txt
