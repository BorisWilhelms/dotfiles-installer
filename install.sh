#!/bin/bash

DOTFILES_BACKUP=.dotfiles-backup
TMP_KEY=$(mktemp)

if [ ! -f "$HOME/.ssh/config" ]; then
    echo "No ssh config found. Assuming running on new installation. Creating intermediate key"
    
    ssh-keygen -t ed25519 -C "intermediate" -f "$TMP_KEY" -q -N "" <<<"y\n"
    export GIT_SSH_COMMAND="ssh -i $TMP_KEY"

    echo "Intermediate key generate. Please register the following public key with github:"
    echo
    cat "$TMP_KEY.pub"
    echo
    read -p "Press enter to continue"
fi

git clone --bare git@github.com:BorisWilhelms/dotfiles.git "$HOME/.dotfiles"

config() {
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" $@
}

config checkout
if [ $? = 0 ]; then
    echo "Checked out dot files."
else
    echo "Backing up pre-existing dot files."
    mkdir -p $DOTFILES_BACKUP
    config checkout 2>&1 | grep -E "\s+\." | awk {'print $1'} | xargs -I{} mv {} $DOTFILES_BACKUP/{}
fi
config checkout
config config status.showUntrackedFiles no
config config diff.tool vimdiff

if [ -f "$TMP_KEY" ]; then
    rm "$TMP_KEY"
    rm "$TMP_KEY.pub"
fi
