HACKON_ACTIVE_ENV=''

if [[ $HACKON_ENV_HOME == "" ]];
then
    HACKON_ENV_HOME=$HOME/.hackenvs
fi

_ensureHackEnv() {
    if [ ! -e $HACKON_ENV_FILE ];
    then
        echo "Creating environment \"$1\""
        touch $HACKON_ENV_FILE;
    fi
}

stophacking() {
    if [[ $HACKON_ACTIVE_ENV = "" ]];
    then
        echo "Not currently hacking on anything!"
        return
    fi
    for field in $_UNSET_VARS
    do
        echo "Unsetting $field"
        unset $field
    done
    for override in $_OVERRIDES
    do
        restore $override
    done

    unset _OVERRIDES
    unset _UNSET_VARS

    PS1=$_OLD_PS1
    unset _OLD_PS1
    unset HACKON_ENV_FILE
    unset HACKON_ACTIVE_ENV
}

override() {
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

restore() {
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

sethackenv() {
    if [[ $HACKON_ACTIVE_ENV = "" ]];
    then
        echo "You must activate a hack environment first!"
        return
    fi
    echo "# Setup $1
    echo $1=$2
    export $1=$2
    _UNSET_VARS=$1:\$_UNSET_VARS
    " >> $HACKON_ENV_FILE
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

mkdir -p $HACKON_ENV_HOME
