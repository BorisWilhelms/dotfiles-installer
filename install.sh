#!/bin/bash
DOTFILES_BACKUP=.dotfiles-backup

git clone --bare git@github.com:BorisWilhelms/dotfiles.git $HOME/.dotfiles

function config {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}

mkdir -p $DOTFILES_BACKUP
config checkout
if [ $? = 0 ]; then
    echo "Checked out dot files.";
else
    echo "Backing up pre-existing dot files.";
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} $DOTFILES_BACKUP/{}
fi;
config checkout
config config status.showUntrackedFiles no
config config diff.tool vimdiff
config config alias.save "!f(){config add $1 && config commit -m "Updates config" && config push}; f"