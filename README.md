# git-push-formatted

When working with projects that have automatic formatting, I might not have it set up to format on save.
I do want to format before pushing to the remote however because we have linting set up that checks the format.
So this project combines git-absorb and a formatter to format the code, commit the changes in the right commit, and pushes with lease.

## Install

```bash
nix profile install github:jelle-bigbridge/git-push-formatted
```

Then you can use `git push-formatted`.
If this is too much to type you can add a alias to git with `git config --edit --global`.
I have added the following:

```
[alias]
    pu = push-formatted
```

## License

You can use this project under the MIT license. See `LICENSE` for the license text.
