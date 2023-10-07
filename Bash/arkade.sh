#!/usr/bin/env bash

# Arkade: Open Source Marketplace For Developer Tools
# https://github.com/alexellis/arkade 


ARKADE_DIR="$HOME/.local/bin"
mkdir -p $ARKADE_DIR

declare -a Tools=("kubectl" 
                  "helm"
                  "terrafrom"
                  "terragrunt"
                  )


if [ -x "$(command -v arkade)" ]; then 
curl -sLS https://get.arkade.dev | sudo sh
fi


arkade update

for tool in ${Tools[@]}; do
arkade get $tool --path $ARKADE_DIR && \
chmod +x $ARKADE_DIR/$tool
done
