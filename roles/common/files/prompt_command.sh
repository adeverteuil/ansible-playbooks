export PROMPT_COMMAND='printf "\033k%s:%s\033\\" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
