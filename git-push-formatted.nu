# Go to repo root
cd (git rev-parse --show-toplevel)

def has-prettier [] {
  not (do -i { open --raw package.json } | from json | get --ignore-errors scripts.prettier | is-empty)
}

let localChanges = if (git stash push -m "git-push-formatted") == "No local changes to save" {
  false
} else {
  true
}

if (has-prettier) {
  ^gum spin --spinner monkey --title 'Prettifying...' --output-on-error -- npm run prettier
}

if (git diff-index --quiet HEAD | complete).exit_code == 1 {
  git add .

  GIT_SEQUENCE_EDITOR=: git absorb --and-rebase
}

if $localChanges {
  git stash pop
}

git push --force-with-lease
