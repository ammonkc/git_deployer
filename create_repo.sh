#!/bin/bash
# @author: Ammon Casey
# http://ammonkc.com
# Created:   08.30.2012

# Modify the following to match your system
GIT_HOME='/srv/git'
HOOK_TEMPLATES=$GIT_HOME/.git_tpl
# --------------END
SED=`which sed`

if [ -z $1 ]; then
	echo "No domain name given"
	exit 1
fi
DOMAIN=$1

# check the domain is valid!
PATTERN="^(([a-zA-Z]|[a-zA-Z][-a-zA-Z0-9]*[a-zA-Z0-9])\.)+([A-Za-z]|[A-Za-z][-A-Za-z0-9]*[A-Za-z0-9])$";
if [[ "$DOMAIN" =~ $PATTERN ]]; then
	DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
	echo "Creating hosting for:" $DOMAIN
else
	echo "invalid domain name"
	exit 1
fi

# set environment defaults to production
read -e -p "Environment (production)? " ENV
if [ -z $ENV ]; then
	ENVIRONMENT='production'
else
	ENVIRONMENT=$ENV
fi

# set framework defaults to codeigniter
read -e -p "Framework? " FW
if [ -z $FW ]; then
	FRAMEWORK=""
else
	FRAMEWORK=$FW
fi

# Change web root directory
read -e -p "Web root directory (public)? " CHROOTDIR
if [ -z $CHROOTDIR ]; then
	WEB_ROOT='public'
else
	WEB_ROOT=$CHROOTDIR
fi

# create git repo
mkdir -p $GIT_HOME/$DOMAIN.git

# init git repo
cd $GIT_HOME/$DOMAIN.git
git init --bare
git config --bool core.bare false
if [[ "$FRAMEWORD" != "" ]] ; then
    git config --path core.worktree /srv/framework/$FRAMEWORK/application/$DOMAIN/$ENVIRONMENT/
else
    git config --path core.worktree "/var/www/html/$DOMAIN/$ENVIRONMENT/$WEB_ROOT/"
fi
git config receive.denycurrentbranch ignore

# Now we need to copy the virtual host template
HOOK=$GIT_HOME/$DOMAIN.git/hooks/post-receive
CLONE_HOOK=$GIT_HOME/$DOMAIN.git/hooks/clone
UPDATE_HOOK=$GIT_HOME/$DOMAIN.git/hooks/update
cp $HOOK_TEMPLATES/post-receive.hook.template $HOOK
cp $HOOK_TEMPLATES/clone.hook.template $CLONE_HOOK
cp $HOOK_TEMPLATES/update.hook.template $UPDATE_HOOK
$SED -i "s/@@APPLICATION@@/$DOMAIN/g" $HOOK
$SED -i "s/@@DEPLOY@@/$ENVIRONMENT/g" $HOOK
$SED -i "s/@@FRAMEWORK@@/$FRAMEWORK/g" $HOOK
$SED -i "s/@@PUBDIR@@/$WEB_ROOT/g" $HOOK

# set file perms and create required dirs!
chmod +x $HOOK

echo -e "\nGit repo with Deploy hook Created for $DOMAIN"


