#!/bin/bash -l

set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Required the GITHUB_TOKEN environment variable."
  exit 1
fi

if [[ -z "$GIT_USER_NAME" ]]; then
    echo "require to set with: GIT_USER_NAME."
  exit 1
fi

if [[ -z "$GIT_EMAIL" ]]; then
  echo "require to set with: GIT_EMAIL."
  exit 1
fi

OWNER="properati"
REPOS=( "properapi" "sellers_api"  )
GEM="overol"
BRANCH_NAME="gem_update/$(date "+%Y%m%d_%H%M%S")"
export PATH="/usr/local/bundle/bin:$PATH"

for repo in "${REPOS[@]}"
do
	git init $repo
	cd $repo
	git remote set-url origin "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$OWNER/$repo"
	hub fetch --depth=1 origin master
	hub checkout master
	hub checkout -b ${BRANCH_NAME}


	if [[ -n "$INPUT_BUNDLER_VERSION" ]]; then
	  gem install bundler -v "$INPUT_BUNDLER_VERSION"
	else
	  gem install bundler
	fi

	gem install bundler-diff

	bundle config --local build.mysql2 "--with-ldflags=-L/usr/local/opt/openssl/lib"
	if [[ -n "$GEM" ]]; then
	  bundle update --source $GEM
	else
	  bundle update
	fi
	bundle diff -f md_table
	BUNDLE_DIFF="$(bundle diff -f md_table)"

	if [ "$(git diff --name-only origin/master --diff-filter=d | wc -w)" == 0 ]; then
	  echo "not update"
	  exit 1
	fi

	export GITHUB_USER="$GITHUB_ACTOR"

	git config --global user.name $GIT_USER_NAME
	git config --global user.email $GIT_EMAIL

	hub add Gemfile Gemfile.lock
	hub commit -m "bundle update"
	hub push origin ${BRANCH_NAME}

	TITLE="bundle update $(date "+%Y%m%d_%H%M%S")"

	PR_ARG="-m \"$TITLE\" -m \"$BUNDLE_DIFF\""

	if [[ -n "$INPUT_REVIEWERS" ]]; then
	  PR_ARG="$PR_ARG -r \"$INPUT_REVIEWERS\""
	fi

	COMMAND="hub pull-request -b master -h $BRANCH_NAME --no-edit $PR_ARG || true"

	echo "$COMMAND"
	sh -c "$COMMAND"
	cd ..
done
