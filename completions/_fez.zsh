#compdef fez

if [[ "${words[-2]}" == "fez" ]] ; then
  _arguments "1: :($(fez --destinations 2> /dev/null))"
else
  compadd $(fez --task-names 2> /dev/null)
fi
