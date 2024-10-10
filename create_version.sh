#!/bin/bash

VERSION=1.0.2

echo "${VERSION} ($(git rev-parse --short HEAD))" > src/version.txt
