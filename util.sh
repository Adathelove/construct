#!/bin/bash

exec >&2

###########
# Gloabls #
###########
STOPONWARN="N"

###########
# Colors  #
###########
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

###################
# informing users #
###################
warn()
{
    echo "[W] $(coloryellow "$1")"

    if [ "x$STOPONWARN" = "xy" ] || [ "x$STOPONWARN" = "xY" ] ; then
        echo "Is this cool? <press enter to be cool | press CTRL-C to be uncool>"
        read cool
    fi

    if [[ $2 =~ ^-?[0-9]+$ ]] ; then
        sleep $2
    fi
    return 1
}

isdebug()
{
    [ -n "$DEBUG" ] && return 0
    return 1
}

debug()
{
    isdebug && echo "[D] $1"
}

alrt()
{
    echo "[A] $(coloralert "$1")"
}

info()
{
        if [ -n "$2" ] ; then
            echo "[*] $1" | tee -a $2
        else
            echo "[*] $1"
        fi
}

fail()
{
        echo "[F] $(colorred "$1")"
        exit 1
}

################
# Common logic #
################

warn_if_exists()
{
    THEFILE=$1
    if [ -z "$THEFILE" ] ; then
        fail "No file supplied to $FUNCNAME"
    fi
    [ -e $THEFILE ] && warn "File exists NOT as expected: \"$THEFILE\""
}

fail_if_exists()
{
    THEFILE=$1
    if [ -z "$THEFILE" ] ; then
        fail "No file supplied to $FUNCNAME"
    fi
    [ -e $THEFILE ] && fail "File exists NOT as expected: \"$THEFILE\""
}

warn_if_not_exists()
{
    THEFILE=$1
    if [ -z "$THEFILE" ] ; then
        fail "No file supplied to $FUNCNAME"
    fi
    [ ! -e $THEFILE ] && warn "File does not exist as expected: \"$THEFILE\""
}

fail_if_not_file()
{
    THEFILE=$1
    if [ -z "$THEFILE" ] ; then
        fail "No file supplied to $FUNCNAME"
    fi
    [ -f $THEFILE ] || fail "File does not exist as expected: \"$THEFILE\""
}

fail_if_not_dir()
{
    THEFILE=$1
    if [ -z "$THEFILE" ] ; then
        fail "No file supplied to $FUNCNAME"
    fi
    [ -d "$THEFILE" ] || fail "Dir does not exist as expected: \"$THEFILE\""
}

fail_if_not_executable()
{
    THEFILE=$1
    if [ -z "$THEFILE" ] ; then
        fail "No file supplied to $FUNCNAME"
    fi
    [ -x $THEFILE ] || fail "File does not exist or is not executable as expected: \"$THEFILE\""
}

fail_if_empty_file_or_noexist()
{
    THEFILE=$1
    if [ -z "$THEFILE" ] ; then
        fail "No file supplied to $FUNCNAME"
    fi
    [ ! -s $THEFILE ] && fail "File doesn't exist or is empty: \"$THEFILE\""
}

###################
# Allow debugging #
###################
func_usage()
{
    echo "[U] Usage: $(coloryellow "${FUNCNAME[1]}"): $(colorred "$1")"
	export UTIL_FUNC_USAGE_PERROR_MISSING_PARAM="y"
}

func_usage_fail_code()
{
	[ -n "$UTIL_FUNC_USAGE_PERROR_MISSING_PARAM" ] && return 1
	return 0
}

ask_user()
{
    msg=$1
    default_result=$2
    if [ -z "$msg" ] ; then
        func_usage "Missing message to tell user"
		return 1
    fi

    if [ "$default_result" = "force" ] ; then
        ask_force "$msg" ; ret=$? ; return $ret
    else
        ans=""
        while [ -z "$ans" ] ; do
            echo  -ne $COLORALERT"$msg: "$COLOR_NONE
            if [[ $default_result =~ [yY][eE][sS]|[yY] ]] ; then read -p"[Yes/no] " ans ; fi
            if [[ $default_result =~ [nN][oO]|[nN] ]] ; then     read -p"[yes/No] " ans ; fi
            case $ans in
                [yY][eE][sS]|[yY])
                  ans="y"
                  ;;
                [nN][oO]|[nN])
                  ans="n"
                  ;;
                *)
                    if [[ $default_result =~ [yY][eE][sS]|[yY] ]] ; then ans="y" ; fi
                    if [[ $default_result =~ [nN][oO]|[nN] ]] ;     then ans="n" ; fi
                  ;;
            esac
        done
        [ "$ans" = "y" ] && return 0
        [ "$ans" = "n" ] && return 1
    fi
	return 1
}
ask_force()
{
    msg=$1
    if [ -z "$msg" ] ; then
        func_usage "Missing message to tell user"
		return 1
    fi

	ans=""
    while [ -z "$ans" ] ; do
        echo -ne $COLORALERT"$msg: "$COLOR_NONE
        echo -ne $COLOR_YELLOW"[yes/no] "$COLOR_NONE
		read ans
        case $ans in
			yes)
			  ans="y"
			  ;;
			no)
			  ans="n"
			  ;;
			*)
                ans=""
			    warn "You must answer full yes or no"
			  ;;
        esac
    done
	[ "$ans" = "y" ] && return 0
	[ "$ans" = "n" ] && return 1
	return 1
}

if_yes()
{
    msg="$1"
    if [ -z "$msg" ] ; then
        func_usage "Missing message to tell user"
		return 1
    fi
	ask_user "$msg" "Y"
}

if_no()
{
    msg="$1"
    if [ -z "$msg" ] ; then
        func_usage "Missing message to tell user"
		return 1
    fi
	ask_user "$msg" "N"
}
if_force_yesno()
{
    msg="$1"
    if [ -z "$msg" ] ; then
        func_usage "Missing message to tell user"
		return 1
    fi
    ask_user "$msg" "force"
}

bann()
{
        echo "=== $(colorgreen "$1") ==="
        if if_yes "Do you wish to continue" ; then
            debug "Running next set of commands"
        else
            fail "User selected to exit"
        fi

}

make_dir()
{
    local the_dir="$1"
    if [ -z "$the_dir" ] ; then
        fail "No the_dir file supplied to $FUNCNAME"
    fi
    if [ ! -d "$the_dir" ] ; then
        debug "$(coloryellow Making directory) $(coloralert  \"$the_dir\")"
        mkdir -vp "$the_dir"
    else
        debug "$(coloralert  "$the_dir already exists"): $(coloryellow "already exists")"
    fi
    warn_if_not_exists "$the_dir"
    if [ ! -d "$the_dir" ]  ; then
        return 1
    else
        return 0
    fi
}

make_dir_or_fail()
{
    local the_dir="$1"
    if [ -z "$the_dir" ] ; then
        fail "No the_dir file supplied to $FUNCNAME"
    fi
    make_dir "$the_dir"
    make_dir_ret=$?
    if [ $make_dir_ret -ne 0 ]  ; then
        fail "Failed to create directory"
    fi

}

remove_file()
{
    thefile="$*"
    local ret=0
    if [ -z "$thefile" ] ; then
        fail "No file supplied to $FUNCNAME"
    fi
    for file in $* ; do
        debug "$(coloryellow Removing) $(coloralert \"$file\")"
        rm -v $file
        warn_if_exists $file
        if [ -e $file ] ; then
            ret=1
        fi
    done
    return $ret
}

move_file()
{
    local src="$1"
    local dst="$2"
    if [ -z "$src" ] ; then
        fail "No src file supplied to $FUNCNAME"
    fi
    if [ -z "$dst" ] ; then
        fail "No dst file supplied to $FUNCNAME"
    fi
    debug "$(coloryellow Moving) $(coloralert \"$src\") to $(coloralert  \"$dst\")"
    mv -v $src $dst
    warn_if_exists $src
    warn_if_not_exists $dst
    if [ -e $src ] || [ ! -e $dst ]  ; then
        return 1
    else
        return 0
    fi
}

copy_file()
{
    local src="$1"
    local dst="$2"
    if [ -z "$src" ] ; then
        fail "No src file supplied to $FUNCNAME"
    fi
    if [ -z "$dst" ] ; then
        fail "No dst file supplied to $FUNCNAME"
    fi
    debug "$(coloryellow Copy) $(coloralert \"$src\") to $(coloralert  \"$dst\")"
    cp -v $src $dst
    warn_if_not_exists $src
    warn_if_not_exists $dst
    if [ ! -e $src ] || [ ! -e $dst ]  ; then
        return 1
    else
        return 0
    fi
}

indent_line()
{
    local allthedata="$1"
    if [ -z "$allthedata" ] ; then
        warn "No allthedata file supplied to $FUNCNAME"
    fi

    local myline=""
    echo "$allthedata" | while read myline ; do echo "    $myline" ; done
}

what_is_file()
{
    local thefile="$1"
    if [ -z "$thefile" ] ; then
        fail "No thefile file supplied to $FUNCNAME"
    fi

    local myline=""
    debug "ls -lh $thefile"
    ls_res=$(ls -lh "$thefile")
    indent_line "$ls_res"
    debug "file $thefile"
    file_res=$(file "$thefile")
    indent_line "$file_res"
}

# Own the file as whoever the script is run as
# rely on pw for sudo root access to chown it
ownit()
{
    local thefile="$1"
    if [ -z "$thefile" ] ; then
        fail "No thefile file supplied to $FUNCNAME"
    fi
    sudoverify
    debug "$(coloryellow Owning) $(coloralert \"$thefile\")"
    sudo chown -v $USER:$USER $thefile
}

# need to sort these
ask_user_exec()
{
    msg=$1
    default_result=$2
    if [ -z "$msg" ] ; then
        func_usage "Missing message to tell user"
		return 1
    fi

	ans=""
    while [ -z "$ans" ] ; do
        echo  -ne $COLOR_GREEN"$msg: "$COLOR_NONE
		if [[ $default_result =~ [yY][eE][sS]|[yY] ]] ; then read -p"[Yes/no] " ans ; fi
		if [[ $default_result =~ [nN][oO]|[nN] ]] ; then     read -p"[yes/No] " ans ; fi
			case $ans in
			[yY][eE][sS]|[yY])
			  ans="y"
			  ;;
			[nN][oO]|[nN])
			  ans="n"
			  ;;
			*)
				if [[ $default_result =~ [yY][eE][sS]|[yY] ]] ; then ans="y" ; fi
				if [[ $default_result =~ [nN][oO]|[nN] ]] ;     then ans="n" ; fi
			  ;;
			esac
    done
	[ "$ans" = "y" ] && return 0
	[ "$ans" = "n" ] && return 1
	return 1
}

if_yes_exec()
{
    msg=$1
    if [ -z "$msg" ] ; then
        func_usage "Missing message to tell user"
		return 1
    fi
	ask_user "$msg" "Y"
}

if_no_exec()
{
    msg=$1
    if [ -z "$msg" ] ; then
        func_usage "Missing message to tell user"
		return 1
    fi
	ask_user "$msg" "N"
}

mkdir_if()
{
    THEFILE=$1
    if [ -z "$THEFILE" ] ; then
        func_usage "No file supplied to $FUNCNAME"
    fi
    [ ! -d $THEFILE ] && mkdir -v "$THEFILE"
}

make_link()
{
    local thefile=$1
    if [ -z "$thefile" ] ; then
        func_usage "No file supplied to $FUNCNAME"
    fi
    [ ! -f $thefile ] && ln -sfv "$thefile"
}
