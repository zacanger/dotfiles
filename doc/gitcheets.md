* Go one step back in history: `git checkout @~1`
* Show commit changes: `git show <commit-sha>`
* Push master branch to origin: `git push origin master`
* List all branches: `git branch -a`
* List remote branches: `git branch -r`
* Sync list of remote branches: `git remote update`
* Checkout remote branch into local repository: `git checkout -t -b <local-name> <remote-name>`
* Create a branch: `git checkout -b <name>`
* Push local branch to remote: `git push origin <remote-name>`
* Merge two branches: `git checkout <target>` & `git merge <source>`
* Merge two branches with squash: `git checkout <target>` & `git merge --squash <source>`
* See what branches are merged into master: `git branch -r --merged master`
* pull changes from the server + rebase (equivalent of git stash save && git pull && git stash pop && git push) + push: `git pull --rebase && git push`
* Set up git inet server: `git daemon --base-path /home/git --verbose`
* Add remote origin: `git remote add origin <url>`
* Fix 'branch not tracking anything': `git config --add branch.master.remote origin` & `git config --add branch.master.merge refs/heads/master`
* Extract patch from a given file: `git diff --patch-with-raw rev1 rev2 patched_file > diff_file`
* Diff with paging: `GIT_PAGER='less -r' git dc`
* Apply a patch: `git apply diff_file`
* Publish branch: `git push origin <name>`
* Delete remote branch: `git push origin :<name>`
* Cherry-pick a commit: `git cherry-pick -n <sha>`
* Revert commit: `git revert -n <sha>`
* Reset HEAD to n commits back: `git reset --hard HEAD~<n>`
* Squash N last commits: `git rebase --interactive --autosquash HEAD~N`
* search git log commits: `git log -S “free text”`
* Prune history: `git gc`, `git gc --aggressive`, `git prune`
* Checkout GitHub PR: `git fetch origin pull/1234/head:local-branch-name`
* Global gitignore: `git config --global core.excludesfile ~/.gitignore`
* Global username & email: `git config --global user.name "Jakub Pawlowicz"` & `git config --global user.email '<email>'`
* Local username & email: `git config user.name "Jakub Pawlowicz"` & git config user.email '<email>'`
* Convert long sha to short one: `git rev-parse --short <sha>`

* remove file from history (can use 'git rm -rf…' to remove files recursively):
    git filter-branch --index-filter 'git rm --cached --ignore-unmatch <path to file>' --prune-empty --tag-name-filter cat -- --all
    git push origin master --force
    rm -rf .git/refs/original/
    git reflog expire --expire=now --all
    git gc --prune=now
    git gc --aggressive --prune=now

* Some useful aliases:
    git config --global alias.aa "add --all"
    git config --global alias.ai "add --interactive"
    git config --global alias.b "branch"
    git config --global alias.ba "branch -a"
    git config --global alias.c "commit"
    git config --global alias.ca "commit --amend"
    git config --global alias.cf '!sh -c "git commit --fixup $@"'
    git config --global alias.co "checkout"
    git config --global alias.col '!sh -c "git checkout -b $@"'
    git config --global alias.cor '!sh -c "git checkout --track -b $@ origin/$@"'
    git config --global alias.cp "cherry-pick"
    git config --global alias.cpa "cherry-pick --abort"
    git config --global alias.cpc "cherry-pick --continue"
    git config --global alias.cs '!sh -c "git commit --squash $@"'
    git config --global alias.d "diff"
    git config --global alias.dc "diff --cached"
    git config --global alias.ds "diff --stat"
    git config --global alias.dsc "diff --stat --cached"
    git config --global alias.fpr '!sh -c "git fetch origin pull/$@/head:$@-pr"'
    git config --global alias.l "log"
    git config --global alias.lf "log --follow"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cblue<%an>%Creset' --abbrev-commit --date=relative --all"
    git config --global alias.m "merge"
    git config --global alias.mb "merge-base master HEAD"
    git config --global alias.ms "merge --squash"
    git config --global alias.pl "pull"
    git config --global alias.ps "push"
    git config --global alias.psc '!sh -c "git push --set-upstream origin \$(git rev-parse --abbrev-ref HEAD)"'
    git config --global alias.psd '!sh -c "git push origin :\$(git rev-parse --abbrev-ref HEAD)"'
    git config --global alias.r "reset HEAD"
    git config --global alias.rb "rebase"
    git config --global alias.rba "rebase --abort"
    git config --global alias.rbc "rebase --continue"
    git config --global alias.rbi "rebase --interactive --autosquash"
    git config --global alias.rbm "rebase --interactive --autosquash origin/master"
    git config --global alias.rh "reset --hard"
    git config --global alias.rs "reset --soft"
    git config --global alias.s "status"
    git config --global alias.sh "show"
    git config --global alias.shs "show --stat"
    git config --global alias.st "stash"

* Get some nice colours:
    git config --global color.diff auto
    git config --global color.status auto
    git config --global color.branch auto

* Branch name and merge status in bash prompt (should go to local or global bash profile):
    function parse_git_dirty {
      [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working directory clean" ]] && echo "*"
    }
    function parse_git_branch {
      git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)]/"
    }
    export PS1='\u@\h \[\033[0;36m\]\w \[\033[0;32m\]$(parse_git_branch)\[\033[0m\]$ '

