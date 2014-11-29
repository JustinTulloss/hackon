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
alias sethackenv=_sethackenv
alias stophacking=_stophacking
alias override=_override
alias restore=_restore
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

    # Unalias all the functions so they don't appear when you're not in an
    # active hackon env.
    unalias restore
    unalias override
    unalias stophacking
    unalias sethackenv
}

_override() {
    if [[ $HACKON_ACTIVE_ENV == "" ]];
    then
        echo "Not currently hacking on anything! Not overriding $1"
        return
    fi
    for envpair in $*
    do
        echo $envpair
        local var=${${(s:=:)envpair}[1]}
        local val=${${(s:=:)envpair}[2]}
        if [[ $var == "" || $val == "" ]]
        then
            echo "usage: override [<ENV_VARIABLE>=<value> ...]"
            return
        fi
        local OLD_VAR=_OLD_$var
        export _OLD_$var=`printenv $var`
        if [[ $OLD_VAR == "" ]];
        then
            echo "$var is not set! Not overriding..."
            return
        fi
        export $var=$val
        _OVERRIDES=$var:$_OVERRIDES
    done
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
    for envpair in $*
    do
        echo $envpair
        local var=${${(s:=:)envpair}[1]}
        local val=${${(s:=:)envpair}[2]}
        if [[ $var == "" || $val == "" ]]
        then
            echo "usage: sethackenv [<ENV_VARIABLE>=<value> ...]"
            return
        fi
        echo "# Setup $var
echo $var=$val
export $var=$val
_HACKON_VARS=$var:\$_HACKON_VARS
" >> $HACKON_ENV_FILE
        export $var=$val
        _HACKON_VARS=$var:$_HACKON_VARS
    done
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
    compdef '_env' override
    compdef '_printenv' restore
fi

mkdir -p $HACKON_ENV_HOME
