#!/bin/bash

VERSION=1.1.1

echo "${VERSION} ($(git rev-parse --short HEAD))" > src/version.txt
