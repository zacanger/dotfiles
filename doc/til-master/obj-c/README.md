# TIL objective-c

## pre-commit

pre-commit removes those nasty trailing whitespace from .m and .h files
add it to your .git/hooks within your xcode project
it just works (lol)

Note:  Commit will abort if you try `git commit --amend` because there are no
changes.  In that case, run with the `--no-verify` flag.
