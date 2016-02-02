#!/bin/bash
# Copyright Mike Harris 2016. GPL 3, see the file LICENSE

#------------ Function declarations
function print-usage {
    echo "This script gives out flash cards.

Usage: blashcards [-o] filename1 [-s sets] [filename2 [-s sets]] ...
       blashcards -p filename1 [filename2]...
           where \"sets\" is a comma separated list of set names.

       --help Displays this message and exits.
       -o Give cards in order. The default is to shuffle.
       -p Show sets available for specified files and exit
       -s Specify sets

    .cards file format:
    -Questions should start on a new line that begins with Q:
    -Answers should start on a new line that begins with A:
    -Optionally, start a new set with the line [setname]
WARNING - input is not sanitized. Do not read arbitrary files 
          if you don't trust them."
    exit 0
}

_order=1
_printing=1

function parse-leading-args {
    _cur=1
    _max=${#1}
    while [ $_cur -lt $_max ]
    do
	case ${1:_cur:1} in
	    p)
		_printing=0
		;;
	    o)
		_order=0
		;;
	    *)
		echo "Unknown option:" ${1:_cur:1}
                echo "Try TUI-flashcards --help"
		exit 0
		;;
	esac
	let "_cur += 1"
    done  
}

#----------------------- Parse the arguments
if [ $# = 0 ] || [ $1 = "help" ] || [ $1 = "--help" ] ; then
    print-usage
fi

while [ ${1:0:1} = "-" ]
do
    parse-leading-args $1
    shift
    if [ $# = 0 ] ; then
	echo "You need to specify at least one flashcard file."
	echo "Try TUI-flashcards --help"
	exit 0
    fi
done

_num_files=0

while [ $# -gt 0 ] ; do
    if [ $1 = "-s" ] ; then
	_sets[ (( $_num_files - 1)) ]=$2
	shift 2
    else
	_files[$_num_files]=$1
	let "_num_files += 1"
	shift
    fi
done	 

#------------------------ print sets if requested
if [ $_printing = 0 ] ; then
    for (( i=0 ; i<_num_files ; i++))
    do
	if ! [ -e ${_files[$i]} ] ; then
	    echo ${_files[$i]} "not found."
	    exit 0
	fi
	echo "Sections in ${_files[$i]}:"
	while read -r _line; do
	    if [[ ! -z _line && ${_line:0:1} = '[' ]] ; then
		echo "-${_line:1:(( ${#_line} - 2 ))}"
	    fi
	done < ${_files[$1]}
    done
    exit 0
fi

#----------------------- load up the questions
_num_questions=-1

for (( i=0 ; i<_num_files ; i++))
do
    _in_set=1
    _in_question=1
    _in_answer=1
    if ! [ -e ${_files[$i]} ] ; then
	echo ${_files[$i]} "not found."
	exit 0
    fi
    if [ -z ${_sets[i]} ] ; then
	_in_set=0
    fi
    while read -r _line || [[ ! $_line = "\n" && -n $_line  ]] ; do
	if [ -z ${_line:0:1} ] ; then
	    continue
	fi
	if [ ${_line:0:1} = '[' ] ; then
	    if [ ! -z ${_sets[i]} ] ; then
		if [[ ${_sets[i]} =~ ${_line:1:(( ${#_line} - 2 ))} ]] ; then
		    _in_set=0
		else
		    _in_set=1
		fi
	    else
		continue
	    fi
	fi
	if [ $_in_set = 0 ] ; then
	    if [[ ${_line:0:1} = 'Q' && ${_line:1:1} = ':' ]] ; then
		let "_num_questions += 1"
		_in_question=0
		_in_answer=1
		_questions[$_num_questions]=$_line"\n"
		continue
	    elif [[ ${_line:0:1} = 'A' && ${_line:1:1} = ':' ]] ; then
		_in_answer=0
		_in_question=1
		_answers[$_num_questions]=$_line"\n"
		continue
	    fi
	    if [ $_in_question = 0 ] ; then
		_questions[$_num_questions]=${_questions[$_num_questions]}$_line"\n"
	    elif [ $_in_answer = 0 ] ; then
		_answers[$_num_questions]=${_answers[$_num_questions]}$_line"\n"
	    fi
	fi
    done < ${_files[$i]}
done

#-------------------------- Set card ordering
for (( i = 0 ; i <= _num_questions ; i++))
do
    _ordering[$i]=$i
done

if [ ! $_order = 0 ] ; then
    for (( i = 0 ; i <= _num_questions ; i++))
    do
	_place=$RANDOM
	let "_place %= _num_questions"
	_temp=${_ordering[$i]}
	_ordering[$i]=${_ordering[$_place]}
	_ordering[$_place]=$_temp
    done
fi

#------------------------- The main loop
_quit=1
_grey='\033[0;37m'
_green='\033[0m'
echo -e "${_green}"
while [ ! $_quit = 0 ] 
do
    _right=0
    _wrong=0
    for (( i=0 ; i<=$_num_questions; i++ ))
    do
	clear
	_place=${_ordering[$i]}
	echo -e ${_questions[$_place]}
	echo -e "${_grey}--Press enter to see answer--${_green}"
	read
	echo -e ${_answers[$_place]}
	echo -e "${_grey}--Press r for right, w for wrong.--${_green}"
	read -N 1 -s
	if [ $REPLY = "r" ] ; then
	    let "_right += 1"
	elif [ $REPLY = "w" ] ; then
	    _ordering[$_wrong]=$_place
	    let "_wrong += 1"
	fi
    done
    let "_num_questions += 1"
    _score=`bc <<< "scale=3; $_right/$_num_questions"`
    echo -e "
No more questions. You marked $_right right and $_wrong wrong.    
Score: $_score"
    if [ $_wrong = 0 ] ; then
       echo "Good job!"
       exit 0
    fi
    while [ 1 = 1 ] ; do
	echo "Want the wrong ones again (y/n)?"
	read -s -N 1
	if [ -z $REPLY ] ; then
	    continue
	fi
	if [ $REPLY = "n" ] ; then
	    _quit=0
	    break
	fi
	if [ $REPLY = "y" ] ; then
	    break
	fi
    done
    let "_num_questions = $_wrong -1"
done
