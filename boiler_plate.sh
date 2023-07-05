#!/usr/bin/env bash

# 
# Boiler Plate
#

#
# Common Scripts
#

# Control vars to source script
SYSTEM_INSTALL="."                                                                                                                                                                                                 
# our_lib = some lib code that's specific to your needs
OUR_LIB=our_lib
INCLUDER_PATH="$SYSTEM_INSTALL:$OUR_LIB"

# Source include guard script
source $SYSTEM_INSTALL/includer.sh

# Source common utils
script_include "util.sh"
AliasRemnantSource
ulg 
# bootstrap the log prefix with a name, maybe the file name
uls "some.sh"

