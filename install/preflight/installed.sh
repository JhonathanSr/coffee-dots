#!/bin/bash

installed_state_path=~/.local/state/coffee-dots/installed
mkdir -p $installed_state_path

for file in $HOME/coffee-dots/migrations/*.sh; do
  touch "$installed_state_path/$(basename "$file")"
done
