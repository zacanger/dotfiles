# Various easy completions

# Bash builtins
complete -A builtin builtin

# Bash options
complete -A setopt set

# Commands
complete -A command command complete coproc exec hash type

# Directories
complete -A directory cd pushd mkdir rmdir

# Functions
complete -A function function

# Help topics
complete -A helptopic help

# Jobspecs
complete -A job disown fg jobs
complete -A stopped bg

# Readline bindings
complete -A binding bind

# Shell options
complete -A shopt shopt

# Signal names
complete -A signal trap

# Variables
complete -A variable declare export readonly typeset

# Both functions and variables
complete -A function -A variable unset

