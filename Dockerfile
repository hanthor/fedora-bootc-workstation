FROM quay.io/fedora/fedora-bootc:42

# Make sure that the rootfiles package can be installed
RUN mkdir -p /var/roothome /data

#install rpmfusion
RUN dnf install -y \
	https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
	https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN dnf update -y --refresh

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
	workstation-product \
	anaconda-tools

RUN dnf install -y \
	anaconda-install-env-deps \
	anaconda-live \
	anaconda-dracut \
	anaconda-webui \
	dracut-live \
	glibc-all-langpacks \
	kernel \
	kernel-modules \
	kernel-modules-extra \
	livesys-scripts \
	rng-tools \
	rdma-core \
	gnome-kiosk


RUN install -dm 0755 -o 0 -g 0 /usr/lib/dracut/dracut.conf.d && \
	echo -e "# Add Live ISO (squashfs image) support\nadd_dracutmodules+=\" dmsquash-live \"" > /usr/lib/dracut/dracut.conf.d/20-atomic-liveiso.conf \
	&& \
	export KERNEL_VERSION="$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')" && \
	stock_arguments=$(lsinitrd "/lib/modules/${KERNEL_VERSION}/initramfs.img"  | grep '^Arguments: ' | sed 's/^Arguments: //') && \
	mkdir -p /tmp/dracut /var/roothome && \
	bash <(/usr/bin/echo "dracut $stock_arguments") && \
	rm -rf /var/* /tmp/*  && \
	mv -v /boot/initramfs*.img "/lib/modules/${KERNEL_VERSION}/initramfs.img" \
	&& \
	systemctl enable livesys.service livesys-late.service \
	&& \
	sed -i 's/^livesys_session=.*/livesys_session="gnome"/' /etc/sysconfig/livesys

# See https://fedoraproject.org/wiki/Changes/UnprivilegedUpdatesAtomicDesktops:
#     Avoid annoying popups when logged in.
RUN dnf install -y fedora-release-ostree-desktop
RUN ostree container commit

# Close once https://gitlab.com/fedora/bootc/base-images/-/issues/28 is merged and released in the base image
RUN rm -rf /var/run && ln -s /run /var/

# Final lint step to prevent easy-to-catch issues at build time
RUN bootc container lint
