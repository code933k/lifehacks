#!/bin/sh
#->
#  Name:        stripped
#  Depends:		[curl|aria2|wget], awk, grep, sed,
#               coreutils, diffutils, file
   VERSION=0.2
#  Home URL:    http://lifehacks.googlecode.com

#  Purpose:		Cache web comic strips, creating collections
#               viewable from image or web browsers.

#  Goal:        Aimed at Ease tedious tasks derived from browsing
#               large lists of comics from many different
#               web domains.
#
#               To become POSIXly shell alternative to
#               dailystrips considering simplicity,
#               portability, reliability and working with a
#               base system.
#
#               i.e., PuppyLinux, DSL, USB, livecd.

#  NOTICE:      Whatever you do with this software
#               beyond the scope of browsing privately your
#               favorite strips is YOUR responsibility
#               alone! Some countries have laws impairing
#               sane recreation, check if your country is an
#               undisclosed dictatorship before using this!

#  Creation:   	Tue Jan 10 2012, 14:20:17 UTC-5
#  Modified:	Fri Jan 20 2012, 10:37:52 UTC-5
#  Insects:		What species? No bugs known,yet.

#  Copyright (C) 2012 Mario García H.
#     <code933k AT gmail DOT com>
#
#  THIS PROGRAM IS FREE SOFTWARE:
#  Distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty
#  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
#  You should have received a copy of the GNU GPL License
#  version 3 or superior along with this program.  If not,
#  see: http://www.gnu.org/licenses/gpl.txt
#<-


LIBSDIR=$HOME/Documentos/Code/lifehacks/Stripped/libs
OVERRIDE=''

if [ ! -d $LIBSDIR ]
then
    cat << ERROR
ERROR: *$LIBSDIR*
is not a directory and cannot be used to
source libraries!

Please check your installation or report
to the BUGS site of your OS distribution.

ERROR
exit 1
fi


# CHECK color support
if [ "$(tput colors)" -ge 8 ]
then
    COLOR_SUPPORT=true
fi


# LOAD functions from libraries
for lib in $LIBSDIR/[0-9][0-9]-*
do
    if [ -s "$lib" ]
    then
        . "$lib"
    fi
done


# READ OPTIONS from stdin
until [ -z "$1" ]
do
    case $1 in
        -d|--debug )
            DEBUG=true
            # DWNLOPT="--verbose $DWNLOPT"
            VERBOSE=true
            set -o xtrace >/dev/null
            set -o verbose >/dev/null
            ;;
        -h|--help )
            shift 1
            if [ -z "$PAGER" ]
            then
                PAGER=less
            fi
            help "$1" | $PAGER
            exit 0
            ;;
        # -p|--proxy )
            # shift 1
            # DWNL_PROXY="$1"
            # ;;
        -u|--usage )
            shift 1
            if [ -z "$PAGER" ]
            then
                PAGER=less
            fi
            help usage | $PAGER
            exit 0
            ;;
        -f|--force)
            FORCED=true
            ;;
        -v|--verbose )
            VERBOSE=true
            # DWNLOPT="--verbose $DWNLOPT"
            _SAVED_WARNINGS=''
            ;;
        -W|--warn )
            WARNINGS=true
            _SAVED_WARNINGS=''
            ;;
        -c|--checkwebz )
            CONNECTIVITY=true
            ;;
        -i|--inhibit )
            DEBUG=true
            ;;
        -e|--edit )
            sanitize
            edit_funstrips || \
            error "Sorry, can't edit funstrips"
            exit 0
            ;;
        -l|--list )
            sanitize
            show_header 'Available web comics short list'
            echo
            echo $COMICS | $FMT -45
            exit 0
            ;;
        -b|--blacklist )
            sanitize
            show_header " Comics you don't want to see"
            echo
            if [ -s "$CONFDIR/blacklist" ]
            then
                cat "$CONFDIR/blacklist"
            else
                echo "No $CONFDIR/blacklist, file"
            fi
            exit 0
            ;;
        -C|--comp )
            sanitize
            echo $COMICS
            exit 0
            ;;
        -s|--show )
            SHOW_ALL=true
            EXIT_NOW=true
            ;;
        -w|--write-html )
            MAKEPAGE=true
            ;;
        -r|--rm-old )
            shift 1
            RM_OLD_F=$2
            ;;
        --version )
            printf "stripped! version $VERSION [$(basename $DWNL)]\n"
            exit 0
            ;;
        * )
            check_overrides $*
            ;;
    esac
    shift 1
done


# PROCESS and feed options
[ -n "$OVERRIDE" ] && COMICS="$OVERRIDE"
[ -n "$SHOW_ALL" ] && show_all
[ -n "$EXIT_NOW" ] && exit 0

sanitize
retrieve
show_warnings

[ -n "$RM_OLD_F" ] && remove_old "$RM_OLD_F"
[ -n "$MAKEPAGE" ] && make_html

exit 0


# vim:tw=60:nowrap:
