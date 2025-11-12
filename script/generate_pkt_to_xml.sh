#!/bin/bash

date=$(date +"%Y%m%d%H%M")
name=$(git config user.name | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
tag="p2x/$name/$date"

git tag "$tag"
git push origin "$tag"