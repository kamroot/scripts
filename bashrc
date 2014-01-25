# $Header: /home/aseem/work/cvs/misc/rcfiles/bashrc,v 1.12 2005/09/07 17:21:33 aseem Exp $
# ident $Id: bashrc,v 1.12 2005/09/07 17:21:33 aseem Exp $

# bashrc for Aseem Asthana. 

# check whether this is a login shell
if [ -z "$PS1" ]; then 
	# this is not an interactive shell, so exit
	return
fi

# Define some colors first:
red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m'              # No Color

#-------------------------------------------------------------
# Automatic setting of $DISPLAY (if not set already)
# This works for linux - your mileage may vary.... 
# The problem is that different types of terminals give
# different answers to 'who am i'......
# I have not found a 'universal' method yet
# added June 10, 2004 from http://www.tldp.org/LDP/abs/html/sample-bashrc.html
#-------------------------------------------------------------

# function save dir
function sd {
	# save all saved directories

	if [ $# -eq 0 ] ; then
		set | grep SD_DIR
		unset op
		unset list
		return
	fi

	# clear all saved sd lists
	if [ X"$1" = X"c" ] ; then
		list=`set | grep SD_DIR | cut -f 1 -d '='`
		for i in $list ; do
			unset $i
		done

		unset i
		unset op
		unset list
		return
	fi

	# see if need to save curr dir
	if [ X"$1" = X"s" ] ; then
		print=0

		# if save dir name is not specified create one
		if [ $# -ne 2 ] ; then
			dir=`pwd`
			name=`basename $dir`
			export SD_DIR_$name=`pwd`
			print=1
		else
			export SD_DIR_$2=`pwd`
			name=$2
			print=0
		fi

		return
	fi

	# go
	if [ X"$1" = X"g" ] ; then
		if [ $# -ne 2 ] ; then
			echo "specify dir to go to"
			return
		fi

		dir_name=SD_DIR_$2
		op=`set | grep $dir_name | cut -f 2 -d'=' | sed s/\ .*//g`
		cd $op
	fi	
	
}

export DISPLAY

######################################################################
## configuration stuff. things that change bash default behaviour   ##
######################################################################
umask 066
set -o noclobber # can't overwrite existing files using >
set -b           # Report  the status of terminated background jobs immedi-
		 # diately
set -o emacs
set -o posix
stty -parenb -istrip cs8
bind -m emacs-standard

# set stuff
shopt -s cdspell         # check spelling in what I type
shopt -s cmdhist         # save multiline commands in one entry in hist
shopt -s checkhash       # check in hash table first
shopt -s extglob         # extended pattern matching
shopt -s histappend      # append rather than overwrite HISTFILE
shopt -s hostcomplete    # hostname completion
shopt -s interactive_comments
			# allow comments in command line
shopt -s lithist        # save mutliline cmds with newline instead of ;
shopt -s nocaseglob     # case insensitive path name completion

# unset stuff
shopt -u checkwinsize   # might slow things down. use resize
shopt -u dotglob        # dont want to look at . files 
shopt -u cdable_vars    # dont want to use vars in cd. use function m instead
shopt -u huponexit      # dont send hup on logout
shopt -u mailwarn       # dont care about this

# path is a anamoly here but is really needed for hash
export PATH="~/bin:/usr/ccs/bin:/bin:/usr/local/gnu/bin:/usr/local/bin"
export PATH="$PATH:/usr/bin:/sbin:/usr/sbin:."

ulimit -c unlimited
# set some hash commands
hash ls rm cvs mutt 2>/dev/null

# unset PS1. we will set it later
unset PS1
######################################################################


######################################################################
## General Functions: Date 24, June 2001                            ##
######################################################################

# functions for prompts. always had stuff for standard prompt. just added
# from the web, functions for powerprompt and fast prompt
if [[ "${DISPLAY#$HOST}" != ":0.0" &&  "${DISPLAY}" != ":0" ]]; then  
    HILIT=${red}   # remote machine: prompt will be partly red
else
    HILIT=${cyan}  # local machine: prompt will be partly cyan
fi


# from http://thelucid.com/2008/12/02/git-setting-up-a-remote-repository-and-doing-an-initial-push/
# added by Aseem, Dec 28, 2013
function gitbranchname {
  git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3
}

function gitbranchprompt {
  local branch=`gitbranchname`
  if [ $branch ]; then printf " [%s]" $branch; fi
}

function stdprompt() {
	# most machines dont have time info about Asia/Calcutta so no
	# idate for them
	if [ -z "$PS1" ] ; then
	    #export PS1="${HILIT}\u\[\033[0m\]\
	    export PS1="\[\033[0;31m\]\u\[\033[0m\]\
@\h \
[\[\033[1;31m\]\W\[\033[0m\]]\
[\[\033[1;34m\]\$(jobcount)\[\033[0m\]]\\033[0;32m\]\$(gitbranchprompt)\[\033[0m\] \$ "
	fi
}


# function adjust_path: given a prepend and append list adjust 
# the path to include them if they exist
function adjust_path() {
	for i in $1 ; do
		if [ -x $i ] ; then
			PATH=$i:$PATH
		fi
	done 
    
	for i in $2; do 
		if [ -x $i ] ; then
			PATH=$PATH:$i
		fi
	done
	export PATH
}

# I got this function from the Bash-Prompt Howto. Used to count the number
# of jobs. Later used in the prompt
#              -- Aseem, Aug 1, 2000@devil
function jobcount (){
	jobs | wc -l | awk '{print $1}'
}

# the following is courtesy of prd@veritas.com
# given either a directory or a symlink name, it will
# cd into that directory or the directory of that symlink.
# the nawk magic is all prd's!

# if at any point nawk becomes too slow I can use what is there in 
# dirname and basename!!
function m() {
	typeset dir
	dir=`ls -ld $1 | nawk '/->/ { sub("/[^/]*$", "", $NF);}; {print $NF}'`
	if [ ! -d "$dir" ] ; then
		echo "$dir: not a dir"
		return
	fi
	cd $dir
	echo $dir
}

# additions from tyt@veritas.com's .bashrc
function        cw   { chmod +w $*; }
function        cx   { chmod +x $*; }
function        k    { kill -9 $*; }

# search current subtree for given name (ignore case, ignore ~ files).
# if no arg, list all regular files in current subtree (ignore ~ files).
#
lfind ()
{
        if [ x$1 = x ]
        then
                find . -type f -print | grep -v "~"
        else
                find . | grep -i $1 | grep -v "~"
        fi
}

if [ "${BASH_VERSION%.*}" \> "2.05" ]; then
    shopt -s progcomp	   # programmable completion
    shopt -s extglob       # necessary
    set a+o nounset        # otherwise some completions will fail
    complete -F _cvs cvs
    complete -F _killall killall killps

    complete -A hostname   rsh rcp telnet rlogin r ftp ping disk
    complete -A export     printenv
    complete -A variable   export local readonly unset
    complete -A enabled    builtin
    complete -A alias      alias unalias
    complete -A function   function
    complete -A user       su mail finger

    complete -A helptopic  help     # currently same as builtins
    complete -A shopt      shopt
    complete -A stopped -P '%' bg
    complete -A job -P '%'     fg jobs disown
    
    complete -A directory  mkdir rmdir
    complete -A directory   -o default cd

    # Compression
    complete -f -o default -X '*.+(zip|ZIP)'  zip
    complete -f -o default -X '!*.+(zip|ZIP)' unzip
    complete -f -o default -X '*.+(z|Z)'      compress
    complete -f -o default -X '!*.+(z|Z)'     uncompress
    complete -f -o default -X '*.+(gz|GZ)'    gzip
    complete -f -o default -X '!*.+(gz|GZ)'   gunzip
    complete -f -o default -X '*.+(bz2|BZ2)'  bzip2
    complete -f -o default -X '!*.+(bz2|BZ2)' bunzip2
# Postscript,pdf,dvi.....
    complete -f -o default -X '!*.ps'  gs ghostview ps2pdf ps2ascii
    complete -f -o default -X '!*.dvi' dvips dvipdf xdvi dviselect dvitype
    complete -f -o default -X '!*.pdf' acroread pdf2ps
    complete -f -o default -X '!*.+(pdf|ps)' gv
    complete -f -o default -X '!*.texi*' makeinfo texi2dvi texi2html texi2pdf
    complete -f -o default -X '!*.tex' tex latex slitex
    complete -f -o default -X '!*.lyx' lyx
    complete -f -o default -X '!*.+(htm*|HTM*)' lynx html2ps
# Multimedia
    complete -f -o default -X '!*.+(jp*g|gif|xpm|png|bmp)' xv gimp
    complete -f -o default -X '!*.+(mp3|MP3)' mpg123 mpg321
    complete -f -o default -X '!*.+(ogg|OGG)' ogg123

    complete -f -o default -X '!*.pl'  perl perl5
fi

# cvs(1) completion
_cvs ()
{
    local cur prev
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    if [ $COMP_CWORD -eq 1 ] || [ "${prev:0:1}" = "-" ]; then
        COMPREPLY=( $( compgen -W 'add admin checkout commit diff \
        export history import log rdiff release remove rtag status \
        tag update' $cur ))
    else
        COMPREPLY=( $( compgen -f $cur ))
    fi
    return 0
}

_killall ()
{
    local cur prev
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

    # get a list of processes (the first sed evaluation
    # takes care of swapped out processes, the second
    # takes care of getting the basename of the process)
    COMPREPLY=( $( /bin/ps -u $USER -o comm  | \
        sed -e '1,1d' -e 's#[]\[]##g' -e 's#^.*/##'| \
        awk '{if ($0 ~ /^'$cur'/) print $0}' ))

    return 0
}

######################################################################
## End of general functions                                         ##
######################################################################

######################################################################
## some declares		  			        ##
######################################################################

declare HISTCONTROL=ignorespace
declare HISTSIZE=800
declare MAILCHECK=1
declare MAIL="$MP/$LOGNAME"
declare FIGNORE=".aux:.dlog:.bbl:.blg:.pstex:.pstex_t:.zi:.zo:.zix"

################################################################
# General Alias Section                                      ###
################################################################

alias p="pwd"
alias n="cat > /dev/null"
alias d="dclock -bg white  -fg blue -bell -date %w%M%d%Y -second"
alias xroot="xsetroot  -bg black -fg brown -name what -mod 8 8"
alias x="xterm -cr red -fg white -bg black -C -sl 3000 -fn -*-fixed-medium-*-*-*-15-*-*-*-*-*-*-* -T Aseem "
alias xl="xlock -mode blank "
alias path="echo $PATH"
alias gv=ghostview
alias c=clear
alias ls="ls -ltr"
alias ll="/bin/ls -lFtr"
alias lpr="lpr -h"
alias l=less
alias lk="links http://kt.zork.net/kernel-traffic/latest.html"
alias lk="links http://www.kerneltraffic.org/kernel-traffic/latest.html"
alias f="mailx -H -f /var/mail/$LOGNAME"
alias rs="source ~/.bashrc" # resource the file
alias g="egrep"
alias lr="ls -lgFqt"
alias h=head
alias t=tail
alias l=less
alias j="jobs -l"
alias linfo="who am i | sed s/.*\(// | sed  s/\)//"
alias r="rlogin"
alias tm="date +%d.%h.%y-%HH"
alias tmm="date +%d.%h.%y-%H:%M"
alias tms="date +%d.%h.%y-%H:%M::%S"

# fg/bg stuff
alias 1='fg %1'                                 # Some "_really_" usefull heh..
alias 2='fg %2'                                 # job-controll shortcuts...
alias 3='fg %3'
alias 4='fg %4'
alias 5='fg %5'
alias 6='fg %6'

alias 11='bg %1'                                # Get jobs to exec.
alias 22='bg %2'                                # in background
alias 33='bg %3'
alias 44='bg %4'
alias 55='bg %5'
alias 66='bg %6'

################################################################
# General Export Section                                     ###
################################################################


export PATH
export EDITOR=vi
export VISUAL=emacs
export ENSCRIPT="-h -2Gr -L67"
export LESS="-im"

export HISTIGNORE="[bf]g:exit:pine:rm"
adjust_path /usr/X11R6/bin ""
export LESS='-X -i -e -M -P%t?f%f :stdin .?pb%pb\%:?lbLine %lb:?bbByte %bb:-...'
export LC_ALL=C
export MAILPATH=/var/mail/$LOGNAME
export HOSTFILE=/etc/hosts
export IGNOREEOF=1

######################################################################
## OS Specific Stuff				        ##
######################################################################

case `uname` in
	 "Linux" )
		# unalias rm, cp and mv. First find out if they are aliased
		# in the first place or not.
		typeset al
		al=`alias rm 2>&1`
		echo $al | grep "not found" 2>&1 >/dev/null;stat=$?
		if [ $stat -ne 0 ] ; then
			unalias rm
		fi
                al=`alias cp 2>&1`
                echo $al | grep "not found" 2>&1 >/dev/null;stat=$?
                if [ $stat -ne 0 ] ; then
                        unalias cp
                fi
                al=`alias rm 2>&1`
                echo $al | grep "not found" 2>&1 >/dev/null;stat=$?
                if [ $stat -ne 0 ] ; then
                        unalias mv
                fi
		alias acro=xpdf
		if [ -r $HOME/.dircolors ] ; then
			eval `dircolors -b $HOME/.dircolors` # setup dircolors 
					       # for bash
		fi
		alias ls="ls -l --color=auto --si -F"
			# --color=auto - detect whether or not 
			# to use color
			# -si show sizes in readable format like 
			# mb kb etc
			# -F extensions after name to show what type it is
		alias du="du --si"
		alias man=info
	    ;; 
esac

######################################################################
## Stuff I might want to print on the tty		        ##
######################################################################

typeset A
A=`tty`
A="(tty) $A :: (hostid) `hostid`"

echo "==> $A"
echo "==> (bash) (version) $BASH_VERSION (build) ${BASH_VERSINFO[5]}"
echo "==> (euid) $EUID (uid) $UID (gid) $GROUPS (hosttype) $HOSTTYPE"
echo "==> (version) $VERSION"

#####################################################################"


#-----------------------
# Greeting, motd etc...
#-----------------------

# Looks best on a black background.....
echo -e "${CYAN}This is BASH ${RED}${BASH_VERSION%.*}${CYAN} - DISPLAY on ${RED}$DISPLAY${NC}"
if [ -x /usr/games/fortune ]; then
    /usr/games/fortune -s     # makes our day a bit more fun.... :-)
fi

function _exit()	# function to run upon exit of shell
{
    echo -e "${RED}Hasta la vista, baby${NC}"
}
trap _exit EXIT

#===============================================================
#

stdprompt

######################################################################
## End of file!!		                                      ##
######################################################################

# contributors(knowing or unknowing!!)
# prd@veritas.com
# scott@cs.indiana.edu
# sederlok@penti.com (http://www.dotfiles.com/files/3/318_profile)
# shardul@veritas.com
