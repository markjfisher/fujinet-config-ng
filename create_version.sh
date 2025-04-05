#!/bin/bash

VERSION=1.0.3

echo "${VERSION} ($(git rev-parse --short HEAD))" > src/version.txt
