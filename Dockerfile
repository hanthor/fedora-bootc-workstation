FROM quay.io/fedora/fedora-bootc:41@sha256:6f383c7d969e591026a2392862f774b6d1d0acf441801b6be9e7260e9fd87e41

# Make sure that the rootfiles package can be installed
RUN mkdir -p /var/roothome /data

#install rpmfusion
RUN dnf install -y \
	https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
	https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN dnf group install -y \
	base-graphical \
	container-management \
	core \
	firefox \
	fonts \
	gnome-desktop \
	guest-desktop-agents \
	hardware-support \
	multimedia \
	networkmanager-submodules \
	printing \
	virtualization \
	workstation-product

RUN dnf install -y \
	bash-completion \
	htop \
	neovim \
	strace \
	tmate \
	tmux \
	vgrep

RUN systemctl set-default graphical.target

# See https://fedoraproject.org/wiki/Changes/UnprivilegedUpdatesAtomicDesktops:
#     Avoid annoying popups when logged in.
RUN dnf install -y fedora-release-ostree-desktop

# Close once https://gitlab.com/fedora/bootc/base-images/-/issues/28 is merged and released in the base image
RUN rm -rf /var/run && ln -s /run /var/

# Final lint step to prevent easy-to-catch issues at build time
RUN bootc container lint
