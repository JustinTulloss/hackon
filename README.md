Hackon
------

Hackon is a small set of shell functions for managing project-specific environment variables. Currently supports zsh and hopefully bash.

### Motivation

As SOA architectures become more common, maintaining a sane development environment becomes more difficult. This project aims to ease a bit of the pain by making it easy to establish a bunch of environment variables for a particular project without permanently poisoning your environment.

- Figure out where services and databases are running consistently between dev and prod
- Test environments can be easily switched to and don't necessarily need to mirror the development environment
- No longer do you need to assume defaults in your code that make development easier. Instead just assert that the environment variables are set and establish a hackon environment to manage them

This is heavily inspired by virtualenv and virtualenvwrapper, though it's not nearly as functional as those tools.

## Usage

#### `hackon <environment name>`
Creates an environment if it doesn't already exist. An environment is just a canonical name for a set of environment variables.

This command reifies the saved environment and prints it out. It also changes your prompt so you can see what environment is currently active.

Only one environment can be active at a time.

This does not unset any of the currently active environment variables. Instead it mixes the saved environment into the current environment.

#### `sethackenv <ENV_VARIABLE>=<value> [<ENV_VARIABLE>=<value>...]`
Sets and saves a variable to `value`. Whenever you restore the environment by calling `hackon <env>`, this environment variable will be restored.

There's currently no command to unset a variable, but you can overwrite the variable by setting it again. It's also trivial to modify by editing `$HACKON_ENV_HOME/<env>`

#### `override <ENV_VARIABLE>=<value> [<ENV_VARIABLE>=<value>...]`
Temporarily overrides an environment variable with the specified `value`. This won't be saved, so if you call `stophacking` this value will be lost. Call `restore <ENV_VARIABLE>` to undo this operation.

This can be applied to any environment variable, not just your variables set by `sethackenv`, but you do need to have some hackon environment active.

#### `restore <ENV_VARIABLE>`
Restores the original value of `ENV_VARIABLE`, assuming it was overridden by `override`.

#### `stophacking`
Exits the current hackon environment and restores the environment to what it was originally.

## Installation

- Run `install.sh` from the hackon repo.

### Advanced Installation

All you need to do is `source <path to hackon.sh>` in your bashrc or zshrc.
