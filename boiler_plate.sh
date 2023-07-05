#!/usr/bin/env bash

# 
# Boiler Plate
#

#
# Common Scripts
#

# Control vars to source script
SYSTEM_INSTALL="."                                                                                                                                                                                                 
AWS_LIB=aws_lib
INCLUDER_PATH="$SYSTEM_INSTALL:$AWS_LIB"

# Source include guard script
source $SYSTEM_INSTALL/includer.sh

# Source common utils
script_include "util.sh"
AliasRemnantSource
ulg 
# bootstrap the log prefix with a name, maybe the file name
uls "some.sh"

