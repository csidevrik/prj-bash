## [@bashly-upgrade completions send_completions]
send_completions() {
  echo $'# myapp completion                                         -*- shell-script -*-'
  echo $''
  echo $'# This bash completions script was generated by'
  echo $'# completely (https://github.com/dannyben/completely)'
  echo $'# Modifying it manually is not recommended'
  echo $''
  echo $'_myapp_completions_filter() {'
  echo $'  local words="$1"'
  echo $'  local cur=${COMP_WORDS[COMP_CWORD]}'
  echo $'  local result=()'
  echo $''
  echo $'  if [[ "${cur:0:1}" == "-" ]]; then'
  echo $'    echo "$words"'
  echo $''
  echo $'  else'
  echo $'    for word in $words; do'
  echo $'      [[ "${word:0:1}" != "-" ]] && result+=("$word")'
  echo $'    done'
  echo $''
  echo $'    echo "${result[*]}"'
  echo $''
  echo $'  fi'
  echo $'}'
  echo $''
  echo $'_myapp_completions() {'
  echo $'  local cur=${COMP_WORDS[COMP_CWORD]}'
  echo $'  local compwords=("${COMP_WORDS[@]:1:$COMP_CWORD-1}")'
  echo $'  local compline="${compwords[*]}"'
  echo $''
  echo $'  case "$compline" in'
  echo $'    \'calculate\'*)'
  echo $'      while read -r; do COMPREPLY+=("$REPLY"); done < <(compgen -W "$(_myapp_completions_filter "--help --verbose -h")" -- "$cur")'
  echo $'      ;;'
  echo $''
  echo $'    \'greet\'*)'
  echo $'      while read -r; do COMPREPLY+=("$REPLY"); done < <(compgen -W "$(_myapp_completions_filter "--help --shout -h")" -- "$cur")'
  echo $'      ;;'
  echo $''
  echo $'    \'help\'*)'
  echo $'      while read -r; do COMPREPLY+=("$REPLY"); done < <(compgen -W "$(_myapp_completions_filter "--help -h")" -- "$cur")'
  echo $'      ;;'
  echo $''
  echo $'    \'g\'*)'
  echo $'      while read -r; do COMPREPLY+=("$REPLY"); done < <(compgen -W "$(_myapp_completions_filter "--help --shout -h")" -- "$cur")'
  echo $'      ;;'
  echo $''
  echo $'    \'c\'*)'
  echo $'      while read -r; do COMPREPLY+=("$REPLY"); done < <(compgen -W "$(_myapp_completions_filter "--help --verbose -h")" -- "$cur")'
  echo $'      ;;'
  echo $''
  echo $'    \'h\'*)'
  echo $'      while read -r; do COMPREPLY+=("$REPLY"); done < <(compgen -W "$(_myapp_completions_filter "--help -h")" -- "$cur")'
  echo $'      ;;'
  echo $''
  echo $'    *)'
  echo $'      while read -r; do COMPREPLY+=("$REPLY"); done < <(compgen -W "$(_myapp_completions_filter "--help --version -h -v c calculate g greet h help")" -- "$cur")'
  echo $'      ;;'
  echo $''
  echo $'  esac'
  echo $'} &&'
  echo $'  complete -F _myapp_completions myapp'
  echo $''
  echo $'# ex: filetype=sh'
}