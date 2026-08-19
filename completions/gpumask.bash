# Bash completion for gpumask

_gpumask() {
  local cur opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  opts="--apply --undo --status --exclude --help --version"

  if [[ "$cur" == -* ]]; then
    COMPREPLY=($(compgen -W "$opts" -- "$cur"))
    return 0
  fi

  local apps="" dir f base
  for dir in "$HOME/.local/share/applications" /usr/share/applications; do
    [[ -d "$dir" ]] || continue
    for f in "$dir"/*.desktop; do
      [[ -f "$f" ]] || continue
      base="${f##*/}"
      apps+="${base%.desktop} "
    done
  done

  COMPREPLY=($(compgen -W "$apps" -- "$cur"))
}

complete -F _gpumask gpumask
