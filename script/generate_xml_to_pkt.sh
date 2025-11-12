#!/bin/bash

date=$(date +"%Y%m%d")
name=$(git config user.name | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
tag="x2p/$name/$date"

git tag "$tag"
git push origin "$tag"