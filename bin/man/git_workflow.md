# GIT WORKFLOW
# (c) Luke Maciak

# Initialize:

  git init

# Check Out:

  git clone username@host:/path/to/repository

# Add Origin:

  git remote add origin <server>

# Commit:

  git add file.ext                              # add a single file to staging
  git add --patch file.ext                      # add changes from file, line by line
  git add .                                     # add everything

  git reset file.ext                            # undo git add - unstage a file

  git commit -m "Commit Message"                # commit with message
  git commit -a                                 # add all, write long msg
  git commit --amend                            # amend changes to previous commit

# Stashing (when you made changes and forgot to pull for example):

  git stash                                     # saves current state for later use
  git stash apply                               # restores/merges stashed state
  git stash unapply                             # reverts stash apply

# Remove / Stop tracking a file:

  git rm --cached <filename>

# Push (upload changes to remote repository):

  git push origin master
  git push --set-upstream origin master         # set default upstream for push
  git push                                      # once you set default

# Pull (update from remote repository):

  git pull                                      # default branch
  git pull origin master                        # for master branch
  git pull origin branchname                    # for specific branch

# If you want to be able to just do git push, git pull:

   git config branch.master.remote origin
   git config branch.master.merge refs/heads/master

# Drop all local commits and revert to origin:

  git fetch origin
  git reset --hard origin/master

# Drop all uncommited changes

  git checkout -- <file>                        # drops only changes for <file>
  git checkout -- .                             # drops all the changes

# Branching:

  git checkout -b branchname                    # create new branch
  git checkout master                           # switch back to master
  git branch -d branchname                      # delete branch

  git push origin branchname                    # push branch

  git merge branchname                          # merge branchname into current


# Tagging:

  git tag -a 1.1 -m "tag description"           # regular tag
  git tag 1.1                                   # lightweight tag
  git tag 1.1 9fceb02                           # tag specific commit
  
  git push --tags                               # push tags

  git tag -d 1.0                                # delete local tag
  git push origin :refs/tags/1.0                # delete tag from remote

# Adding a Submidule

  git submodule add usename@host:/path/to/repo foldername

# Initializing sumbodule in a cloned project

  git submodule init
  git submodule update

# Rebasing

  git rebase -i HEAD~3                          # rebase last 3 commits

# Diffs

  git diff                                      # diff against working area
  git diff --staged                             # dif against staged (added) files

# List files that were modified between TAG2 and TAG1

  git diff --name-status TAG2 TAG1
  git diff --name-status TAG2 TAG1 | wc -l      # count modified files
