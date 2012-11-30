_fez()
{
  local cur prev completion
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  if [ $prev == "fez" ]; then
    completion="destinations"
  else
    completion="task-names"
  fi
  COMPREPLY=( $(compgen -W "$(fez ${completion} 2> /dev/null | GREP_OPTIONS='' grep -v '(in')" -- ${cur}) )
  return 0
}
complete -F _fez fez
