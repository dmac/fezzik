#compdef fez

if [[ "${words[-2]}" == "fez" ]] ; then
  compadd $(fez --destinations 2> /dev/null | GREP_OPTIONS='' grep -v '(in')
else
  compadd $(fez --task-names 2> /dev/null | GREP_OPTIONS='' grep -v '(in')
fi
