#!/usr/bin/env bash

# Arkade: Open Source Marketplace For Developer Tools
# https://github.com/alexellis/arkade 


ARKADE_DIR="$HOME/.local/bin"

declare -a Tools=("kubectl" 
                  "helm"
                  )


mkdir -p $ARKADE_DIR
curl -sLS https://get.arkade.dev | sudo sh
arkade update

for val in ${Tools[@]}; do
 arkade get $tool --path $ARKADE_DIR
done

chmod +x $ARKADE_DIR/*



