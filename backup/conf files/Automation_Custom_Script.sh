#!/bin/bash
# Common configuration and functions for all audio system scripts
# This file should be sourced by all other scripts

# Set strict error handling
set -e

git clone https://github.com/klh/hojtaler
cd hojtaler
/src/scripts/setup.sh