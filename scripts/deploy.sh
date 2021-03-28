#!/usr/bin/env bash

# This script is executed by GitHub Actions when a PR is merged (i.e. in the `deploy` step).
set -ex

function initialize {
  if [ -z "$TLDRHOME" ]; then
    export TLDRHOME=${GITHUB_WORKSPACE:-$(pwd)}
  fi

  export TLDR_ARCHIVE="tldr.zip"
  export SITE_HOME="$HOME/tldr/site"
  export SITE_REPO_SLUG="taylorcox75/tldr"

  # Configure git.
  git config --global diff.zip.textconv "unzip -c -a"
  ./scripts/build.sh
  # Decrypt and add deploy key.
#  eval "$(ssh-agent -s)"
 # cp /home/tmcox/.ssh/id_rsa .  
 # chmod 600 id_rsa
 # ssh-add id_rsa
}

function upload_assets {
#  git clone --quiet --depth 1 -b pages git@github.com:${SITE_REPO_SLUG}.git "$SITE_HOME"
  cd $SITE_HOME
  git pull
  cd -
  mv -f "$TLDR_ARCHIVE" "$SITE_HOME/assets/"
  cp -f "$TLDRHOME/index.json" "$SITE_HOME/assets/"

  # Copy PDF to assets
  if [[ -f "${TLDRHOME}/scripts/pdf/tldr-pages.pdf" ]]; then
    cp -f "${TLDRHOME}/scripts/pdf/tldr-pages.pdf" "${SITE_HOME}/assets/tldr-book.pdf"
  fi

  cd "$SITE_HOME"
  git add -A
  git commit -m "[GitHub Actions] uploaded assets after commit tldr-pages/tldr@${GITHUB_SHA}"
  git push -q

  echo "Assets (pages archive, index) deployed to static site."
}

###################################
# MAIN
###################################

initialize
upload_assets
