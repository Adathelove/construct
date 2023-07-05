#!/usr/bin/env bash

INCLUDER_GLOBAL_SCRIPT_NAME="includer.sh"

##############################
# Bare bones debug functions #
##############################

COLOR_YELLOW=$(tput setaf 3)
COLOR_RED=$(tput setaf 1)
COLOR_GREEN=$(tput setaf 2)
COLOR_LIGHT_BLUE=$(tput setaf 6)
COLOR_NONE=$(tput sgr0)
COLORALERT=$COLOR_LIGHT_BLUE

colorgreen()
{
    echo  -en $COLOR_GREEN"$1"$COLOR_NONE
}

coloryellow()
{
    echo  -en $COLOR_YELLOW"$1"$COLOR_NONE
}

colorred()
{
    echo  -en $COLOR_RED"$1"$COLOR_NONE
}

coloralert()
{
    echo  -en $COLORALERT"$1"$COLOR_NONE
}

JOY_FACE="$(colorgreen \":\)\")"
YUP_FACE="$(coloralert \":]\")"
HUH_FACE="$(coloryellow \"\:\|\")"
SAD_FACE="$(colorred \":\(\")"

function is_includer_debug
{
    # echo "INCLUDER_DEBUG=\"$INCLUDER_DEBUG\""
    if [[ -n "${INCLUDER_DEBUG}" ]] && [[ ${INCLUDER_DEBUG}=~"[yY][eE][sS]|[yY]" ]] ; then
       return 0
   else
       return 1
    fi
}


shopt -s expand_aliases
# Easy alias to call in functionos
alias ila="ils \${FUNCNAME[0]}"

# Includer Log Set
function ils()
{
    INCLUDER_IL_PREFIX_OLD=$INCLUDER_IL_PREFIX
    INCLUDER_IL_PREFIX_NEW="$1"
    if [ -z "${INCLUDER_IL_PREFIX_NEW}" ] ; then
        INCLUDER_IL_PREFIX_NEW="${INCLUDER_GLOBAL_SCRIPT_NAME}"
    fi
    INCLUDER_IL_PREFIX="$INCLUDER_IL_PREFIX_NEW"
}


# Includer Log Reset
function ilr()
{
    INCLUDER_IL_PREFIX_NEW=""
    INCLUDER_IL_PREFIX="$INCLUDER_IL_PREFIX_OLD"
    INCLUDER_IL_PREFIX_OLD=""
}

# Includer Log
function ill()
{
    is_includer_debug || return 0


    string1="$1 ${INCLUDER_IL_PREFIX}"
    shift
    string2="$*"
    padding="                                              "                                  #  PADDING SPACES #
    printf "%s%s %s\n" "$string1" "${padding:${#string1}}" "$string2"

}

function joy()
{
    ill "$JOY_FACE" "$*"
}
function huh()
{
    ill "$HUH_FACE" "$*"
}
function yup()
{
    ill "$YUP_FACE" "$*"
}
function sad()
{
    ill "$SAD_FACE" "$*"
}

wow()
{
    local color_green=$(tput setaf 2)
    local color_light_blue=$(tput setaf 6)
    local color_none=$(tput sgr0)
    is_includer_debug && echo  -e ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" $COLOR_GREEN"$1"$COLOR_NONE "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
}

##########################
# Bare bones IFS control #
##########################

ifsnew()
{
    if [ -n "${IFS_NEW}" ]  ; then
        sad "returning error: IFS_NEW=\"${IFS_NEW}\" and SHOULD be empty"
        return 1
    fi
    IFS_NEW="$1"
    if [[ ${#IFS_NEW} -ge 2 ]] ; then
        sad "returning error: IFS_NEW=\"${IFS_NEW}\" SHOULD be exactly one character long"
        return 1
    fi
    IFS_OLD="$IFS"
    IFS="$IFS_NEW"
    return 0
}

ifsnew_clear()
{
    if [ -n "${IFS_NEW}" ]  ; then
        IFS_NEW=""
        unset IFS_NEW
        IFS="$IFS_OLD"
        joy "IFS_NEW=\"${IFS_NEW}\" yay we cleared it __AND__ reset the IFS_OLD"
        return 0
    else
        sad "returning error: IFS_NEW=\"${IFS_NEW}\" empty and we wanted to CLEAR IT"
        return 1
    fi
}

####################################
# script_include support functions #
####################################


function normailize_path()
{
    ila

    if [ -n "$INCLUDER_PATH" ] ; then
            # normailize to many slashes to just one
            INCLUDER_PATH=$(echo "$INCLUDER_PATH" | sed -E 's/\/+$//')
            INCLUDER_PATH="${INCLUDER_PATH}/"
            is_includer_debug && huh "INCLUDER_PATH set to: \"$INCLUDER_PATH\""
    else
            INCLUDER_PATH="."
            is_includer_debug && yup "INCLUDER_PATH set to: \"$INCLUDER_PATH\""
    fi

    ilr
}

function script_include()
{
	local script_script="$1"
	local script_source=""

    ila

    yup "script_include \"$*\""

    normailize_path "$INCLUDER_PATH"

    #INCLUDER_PATH=$PATH
    wow "INCLUDER_PATH=\"$INCLUDER_PATH\""
    ifsnew ":"
    read -ra my_array <<< "$INCLUDER_PATH"
    ifsnew_clear
    for i in "${my_array[@]}" ; do
        script_source="${i}/$script_script"
        search_these_locations="$search_these_locations:$i"
        #echo "------------------->  $script_source"
    done

    yup "Search Paths are: \"$search_these_locations\""

    for i in "${my_array[@]}" ; do
        script_source="${i}/$script_script"

        yup "Seraching in: \"$i\""

        #echo "------------------->  $script_source"

        #if [ -r "$script_source" ]  ; then
            #echo "IS -r"
        #else
            #echo "NOT -r"
        #fi


        local do_the_include=""
        do_the_include=0

        if [ -r "$script_source" ]  ; then

            #echo "Found $script_source" 

            mystring="$INCLUDER_GUARD"
            substring="${script_script}"
            if [[ "$mystring" == "INCLUDER_GUARD" ]] ; then
                wow "mystring == INCLUDER_GUARD !! TRUE"
                export INCLUDER_GUARD
                #INCLUDER_GUARD="$( dirname "${BASH_SOURCE[0]}" )/includer.sh" # include includer
                INCLUDER_GUARD="includer.sh" # include includer
                do_the_include=1
            else
                wow "$mystring != INCLUDER_GUARD !! TURE"
                wow "$substring                         inside                  $mystring                     ???"
                if [[ "${mystring/${substring}}" == ${mystring} ]] ; then
                    wow "                                    YES IT IS                                            "
                    wow "\${mystring/\${substring}} == \${mystring}"
                    wow "${mystring/\${substring}} == ${mystring}"
                    wow "\${mystring/${substring}} == \${mystring}"
                    wow "=========================================="
                    wow "${mystring/${substring}} == ${mystring}"
                    wow "didn't find it so DO THE INCLUDE"
                    do_the_include=1
                else
                    wow "                                    YES IT IS                                            "
                    wow "\${mystring/\${substring}} == \${mystring}"
                    wow "${mystring/\${substring}} == ${mystring}"
                    wow "\${mystring/${substring}} == \${mystring}"
                    wow "=========================================="
                    wow "${mystring/${substring}} == ${mystring}"
                    wow "DID FIND IT "
                fi
            fi

            if [ $do_the_include -eq 1 ]; then # need to inlucde it
                export INCLUDER_GUARD="$INCLUDER_GUARD:$script_script"
                wow "updating INCLUDER_GUARD: $INCLUDER_GUARD"
                echo "[*] Sourcing: $script_source"
                source "$script_source"
            else
                wow "do_the_include is NOT1 so not updating INCLUDER_GUARD: $INCLUDER_GUARD"
            fi


            FINALLY_FOUND="y"

            joy "FOUND source: $script_script"

            return 0

        else
            #echo "i: \"$i\""

            #ls -ld "$i"
            #file "$i"
            echo "[W] Couldn't source: $script_source"
        fi
    done
    if [[ "x$FINALLY_FOUND" == "xy" ]] ; then
        huh "NEVER FOUND source: $script_script  ............................. HOWEVER ...........................   did we include it already in ___THIS___ run of the shell?"
        mystring="$INCLUDER_GUARD"
        substring="${script_script}"
        wow "$substring                         inside                  $mystring                     ???              THEN we will be ok"
        if [[ -n "${mystring/${substring}}" ]] ; then
            wow "we DID include it!!!!"
        else
            wow "we did not??????????????????????????????"
            exit 1
        fi
    fi

    ilr

}

function includer_init()
{

    ila

    joy "includer_init"
    joy "Configure Globals"

    # if first use of INCLUDER_GUARD set to discoverable state
    if [ -z "$INCLUDER_GUARD" ] ; then
        export INCLUDER_GUARD="INCLUDER_GUARD"
    else
        huh "includer_init:"
    fi

    # if not set then set to empty string
    export INCLUDER_PATH=${INCLUDER_PATH:-""}

    ilr
}

# "main" for when soruced
function includer_main()
{
    ila

    joy "Includer main"
    joy "call includer_init"
    includer_init

    ilr
}


ila
joy "call includer_main"
includer_main
