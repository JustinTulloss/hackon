# You must source this! Executing it will do nothing for you

HACKON_ACTIVE_ENV=

if [[ $HACKON_ENV_HOME == "" ]];
then
    HACKON_ENV_HOME=$HOME/.hackenvs
fi

_ensureHackEnv() {
    if [ ! -e $HACKON_ENV_FILE ];
    then
        echo "Creating environment \"$1\""
        cat > $HACKON_ENV_FILE <<-EOF
export sethackenv=_sethackenv
export stophacking=_stophacking
export override=_override
export restore=_restore
EOF
    fi
}

_stophacking() {
    if [[ $HACKON_ACTIVE_ENV = "" ]];
    then
        echo "Not currently hacking on anything!"
        return
    fi
    # First restore everything we overrode
    for override in ${(s.:.)_OVERRIDES}
    do
        restore $override
    done

    # Then unset anything that was set just for this environment
    for field in ${(s.:.)_HACKON_VARS}
    do
        echo "Unsetting $field"
        unset $field
    done

    unset _OVERRIDES
    unset _HACKON_VARS

    PS1=$_OLD_PS1
    unset _OLD_PS1
    unset HACKON_ENV_FILE
    unset HACKON_ACTIVE_ENV

    # Unset all the functions so they don't appear when you're not in an
    # active hackon env.
    unset restore
    unset override
    unset stophacking
    unset sethackenv
}

_override() {
    if [[ $1 == "" || $2 == "" ]];
    then
        echo "usage: override <ENV_VARIABLE> <value>"
        return
    fi
    if [[ $HACKON_ACTIVE_ENV == "" ]];
    then
        echo "Not currently hacking on anything! Not overriding $1"
        return
    fi
    local OLD_VAR=_OLD_$1
    export _OLD_$1=`printenv $1`
    if [[ $OLD_VAR == "" ]];
    then
        echo "$1 is not set! Not overriding..."
        return
    fi
    export $1=$2
    _OVERRIDES=$1:$_OVERRIDES
}

_restore() {
    if [[ $1 == "" ]];
    then
        echo "usage: restore <ENV_VARIABLE>"
        return
    fi
    local OLD_VAL=`printenv _OLD_$1`
    if [[ $OLD_VAL == "" ]];
    then
        echo "No old value found for $1, cannot restore!"
    fi
    export $1=$OLD_VAL
    unset _OLD_$1
}

_sethackenv() {
    if [[ $HACKON_ACTIVE_ENV == "" ]];
    then
        echo "You must activate a hack environment first!"
        return
    fi
    if [[ $1 == "" || $2 == "" ]];
    then
        echo "usage: sethackenv <ENV_VARIABLE> <value>"
        return
    fi
    echo "# Setup $1
echo $1=$2
export $1=$2
_HACKON_VARS=$1:\$_HACKON_VARS
" >> $HACKON_ENV_FILE
    export $1=$2
    _HACKON_VARS=$1:$_HACKON_VARS
}

hackon() {
    if [[ $HACKON_ACTIVE_ENV != "" ]];
    then
        echo "You must first stop hacking on $HACKON_ACTIVE_ENV!"
        echo "Run \`stophacking\` to do this."
        return
    fi
    HACKON_ENV_FILE=$HACKON_ENV_HOME/$1
    _ensureHackEnv $1
    source $HACKON_ENV_FILE
    HACKON_ACTIVE_ENV=$1
    _OLD_PS1=$PS1
    PS1="[%{$fg[red]%}$HACKON_ACTIVE_ENV%{$reset_color%}]"$PS1
}

# Shell completions for ZSH, they're pretty simple
if [[ $SHELL =~ 'zsh' ]]
then
    compdef '_files -W $HACKON_ENV_HOME' hackon
    compdef '_printenv' override
    compdef '_printenv' restore
fi

mkdir -p $HACKON_ENV_HOME
