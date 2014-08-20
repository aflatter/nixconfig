#!/bin/bash
set -e

REPO_URL="https://github.com/aflatter/nixconfig"

if ! command -v curl > /dev/null; then
	echo "Please install curl to continue."
	exit 1
fi

pushd $HOME

# We need Nix of course.
if [ ! -d /nix ]; then
	echo "Installing Nix..."
	bash <(curl --silent https://nixos.org/nix/install)
	# Load Nix and make it follow the XDG spec.
	cat >> .profile <<-'EOF'
		[[ -z $XDG_CONFIG_HOME ]] && export XDG_CONFIG_HOME="$HOME/.config"
		source $HOME/.nix-profile/etc/profile.d/nix.sh
	EOF
	source .profile
else
	echo "Nix is already installed, moving on..."
fi

# If the path is not overriden, fetch the configuration from the repository.
if [ -z $NIXCONFIG_PATH ]; then
	NIXCONFIG_PATH='$XDG_CONFIG_HOME/nix'
	[[ -d $NIXCONFIG_PATH ]] || mkdir $NIXCONFIG_PATH

	echo "Downloading configuration tarball to $NIXCONFIG_PATH"
	# At this point, we may not have git available yet, so let's fetch a tarball.
	curl --silent --location $REPO_URL/archive/master.tar.gz | \
		tar -xz --directory $NIXCONFIG_PATH --strip-components=1
else
	echo "Using local configuration: $NIXCONFIG_PATH"
fi

# Append configuration path to .profile if necessary.
if ! grep -Fq "NIXPKGS_CONFIG" .profile; then
	cat >> .profile <<-EOF
		export NIXPKGS_CONFIG="$NIXCONFIG_PATH/config.nix"
	EOF

	source .profile
fi


# Now we install our standard environment.
nix-env -i userEnv

popd
