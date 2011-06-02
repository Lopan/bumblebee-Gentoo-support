# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

DESCRIPTION="Bumblebee, the right hand of Optimus-Prime :)"
HOMEPAGE="https://github.com/MrMEEE/bumblebee"
# SRC_URI="./bumblebee-1.1.2.tar.gz"

LICENSE="BEER-WARE"
SLOT="0"
KEYWORDS="amd64"
IUSE="nvidia"

CATEGORY="app-misc"

MERGE_TYPE="binary"

DEPEND="x11-drivers/nvidia-drivers
	x11-apps/mesa-progs"
#	sys-libs/libselinux"
RDEPEND="${DEPEND}"


pkg_setup() {
	einfo "<> pkg_setup()"

	ewarn "THIS SCRIPT MUST BE RUN WITH SUDO"

	mkdir -p /etc/bumblebee/configs_backup
	CONF_BACKUP_DIR=/etc/bumblebee/configs_backup

	ROOT_UID=0

	# Determine Arch x86_64 or i686
	ARCH=`uname -m`

#	echo "[ ${ROOT_UID} ]"
#	echo "[ ${HOME} ]"
#	echo "[ ${ARCH} ]"
#	echo "[ ${PORTAGE_TMPDIR} ]"
#	echo "[ ${S} ]"
#	echo "[ ${D} ]"

#	mkdir -p ${S}

	if [ $UID != $ROOT_UID ]; then
		echo "You don't have sufficient privileges to run this script."
		#echo
		#echo 
		#exit 1
		die "Please run the script with: sudo install.sh"
	fi

	if [ $HOME = /root ]; then
		echo "Do not run this script as the root user"
		#echo
		#echo 
		#exit 2
		die "Please run the script with: sudo install.sh"
	fi

	echo
	echo "Welcome to the bumblebee installation v.1.1.2"
	echo "Licensed under BEER-WARE License and GPL"
	echo
	echo "This will enable you to utilize both your Intel and nVidia card"
	echo
	echo "Please note that this script will only work with 64-bit Debian Based machines"
	echo "and has only been tested on Ubuntu Natty 11.04 but should work on others as well"
	echo "from version v1.1 support for 32-bit Ubuntu has been added"
	echo "I will add support for RPM-based distributions later.. or somebody else might..."
	echo "Remember... This is OpenSource :D"
	echo

	# Back up configuration
	einfo "Backing up your Configuration"
	if [ `cat /etc/bash/bashrc |grep VGL |wc -l` -ne 0 ]; then
		cp "${CONF_BACKUP_DIR}"/bashrc.optiorig /etc/bash/bashrc
	fi
	cp -n /etc/bash/bashrc "${CONF_BACKUP_DIR}"/bashrc.optiorig
	cp -n /etc/modprobe.d/blacklist.conf "${CONF_BACKUP_DIR}"/blacklist.conf.optiorig
	cp -n /etc/conf.d/modules "${CONF_BACKUP_DIR}"/modules.optiorig
	cp -n /etc/X11/xorg.conf "${CONF_BACKUP_DIR}"/xorg.conf.optiorig

	# To remember: when will putting back those configs need to put them in their directories
	# This will become needed when will write uninstal routine.
	# ${CONF_BACKUP_DIR}/bashrc.optiorig		/etc/bash/bashrc
	# ${CONF_BACKUP_DIR}/blacklist.conf.optiorig	/etc/modprobe.d/blacklist.conf
	# ${CONF_BACKUP_DIR}/modules.optiorig		/etc/conf.d/modules
	# ${CONF_BACKUP_DIR}/xorg.conf.optiorig		/etc/X11/xorg.conf

	# Setting up Evironment variables
	#
	# "The Image Transport is how the images are transferred from the"
	# "nVidia card to the Intel card, people has different experiences of"
	# "performance, but just select the default if you are in doubt."
	#
	# "I recently found out that yuv and jpeg both has some lagging"
	# "this is only noticable in fast moving games, such as 1st person"
	# "shooters and for me, its only good enough with xv, even though"
	# "xv sets down performance a little bit."
	#
	# "1) YUV"
	# "2) JPEG"
	# "3) PROXY"
	# "4) XV (default)"
	# "5) RGB"

	IMAGETRANSPORT="xv"

	# Setting monitor connection type

	CONNECTEDMONITOR="CRT-0"

	# Install prerequisites: (handled by dependencies)
	# echo "Installing needed packages"
	# apt-get -y install nvidia-current
	# emerge -vta x11-drivers/nvidia-drivers
	# emerge -vta media-video/nvidia-settings
	# env-update
	# source /etc/profile

#	eend ${?}
}

#src_unpack() {
#	ebegin "<> src_unpack()"
#	mkdir -p ${S}
#	eend ${?}
#}

#src_prepare() {
#	ebegin "<> src_prepare()"
#	eend ${?}
#}

#src_install() {
#	ebegin "Installing bumblebee src..."
#	eend ${?}
#}

#pkg_config() {
#	ebegin "<> pkg_config()"
#	eend ${?}
#}



pkg_preinst() {
	einfo "<> pkg_preinst()"

	mkdir -p /opt/VirtualGL/fakelib/64
	mkdir -p /opt/VirtualGL/bin
	mkdir -p /opt/VirtualGL/include

	echo
	einfo "Installing Optimus Configuration and files"

	insinto /etc/X11
	newins "${FILESDIR}/etc/X11/xorg.conf.intel" xorg.conf || die
	doins "${FILESDIR}/etc/X11/xorg.conf.nvidia" || die
	# cp ${FILESDIR}/etc/X11/xorg.conf.intel /etc/X11/xorg.conf
	# cp ${FILESDIR}/etc/X11/xorg.conf.nvidia /etc/X11/

	rm -rf /etc/X11/xdm-optimus
	cp -a ${FILESDIR}/etc/X11/xdm-optimus /etc/X11/

#	cp ${FILESDIR}/xdm-optimus.script /etc/init.d/xdm-optimus
	cp ${FILESDIR}/etc/init.d/xdm-optimus /etc/init.d/xdm-optimus
	cp ${FILESDIR}/etc/conf.d/xdm-optimus /etc/conf.d/xdm-optimus

	cp ${FILESDIR}/etc/modprobe.d/virtualgl.conf /etc/modprobe.d/
	cp ${FILESDIR}/usr/local/bin/optimusXserver /usr/local/bin/

	# Conducting "installation" of VGL, probably will be replaced in future by some
	# existent ebuilds
	if [ "$ARCH" = "x86_64" ]; then
		cp ${FILESDIR}/usr/bin/xdm-optimus-64.bin /usr/bin/xdm-optimus
		# dpkg -i install-files/VirtualGL_amd64.deb
		# Install VirtualGL package (manually this time)
		cp ${FILESDIR}/opt/VirtualGL/bin/cpustat	/opt/VirtualGL/bin/cpustat
		cp ${FILESDIR}/opt/VirtualGL/bin/glxinfo	/opt/VirtualGL/bin/glxinfo
		cp ${FILESDIR}/opt/VirtualGL/bin/glxspheres	/opt/VirtualGL/bin/glxspheres
		cp ${FILESDIR}/opt/VirtualGL/bin/glxspheres64	/opt/VirtualGL/bin/glxspheres64
		cp ${FILESDIR}/opt/VirtualGL/bin/nettest	/opt/VirtualGL/bin/nettest
		cp ${FILESDIR}/opt/VirtualGL/bin/tcbench	/opt/VirtualGL/bin/tcbench

		cp ${FILESDIR}/usr/bin/vglclient	/usr/bin/vglclient
		ln -s /usr/bin/vglclient	/opt/VirtualGL/bin/vglclient

		cp ${FILESDIR}/usr/bin/vglconfig	/usr/bin/vglconfig
		ln -s /usr/bin/vglconfig	/opt/VirtualGL/bin/vglconfig

		cp ${FILESDIR}/usr/bin/vglconnect	/usr/bin/vglconnect
		ln -s /usr/bin/vglconnect	/opt/VirtualGL/bin/vglconnect

		cp ${FILESDIR}/usr/bin/vglgenkey	/usr/bin/vglgenkey
		ln -s /usr/bin/vglgenkey	/opt/VirtualGL/bin/vglgenkey

		cp ${FILESDIR}/usr/bin/vgllogin	/usr/bin/vgllogin
		ln -s /usr/bin/vgllogin	/opt/VirtualGL/bin/vgllogin

		cp ${FILESDIR}/usr/bin/vglrun	/usr/bin/vglrun
		ln -s /usr/bin/vglrun	/opt/VirtualGL/bin/vglrun

		cp ${FILESDIR}/usr/bin/vglserver_config	/usr/bin/vglserver_config
		ln -s /usr/bin/vglserver_config	/opt/VirtualGL/bin/vglserver_config

		cp ${FILESDIR}/usr/lib/libdlfaker.so	/usr/lib64/libdlfaker.so
		cp ${FILESDIR}/usr/lib32/libdlfaker.so	/usr/lib32/libdlfaker.so

		cp ${FILESDIR}/usr/lib/libgefaker.so	/usr/lib64/libgefaker.so
		cp ${FILESDIR}/usr/lib32/libgefaker.so	/usr/lib32/libgefaker.so

		cp ${FILESDIR}/usr/lib32/librrfaker.so	/usr/lib32/librrfaker.so
		ln -s /usr/lib32/librrfaker.so	/opt/VirtualGL/fakelib/libGL.so

		cp ${FILESDIR}/usr/lib/librrfaker.so	/usr/lib64/librrfaker.so
		ln -s /usr/lib64/librrfaker.so	/opt/VirtualGL/fakelib/64/libGL.so

		cp ${FILESDIR}/usr/include/rr.h	/usr/include/rr.h
		ln -s /usr/include/rr.h	/opt/VirtualGL/include/rr.h

		cp ${FILESDIR}/usr/include/rrtransport.h	/usr/include/rrtransport.h
		ln -s /usr/include/rrtransport.h	/opt/VirtualGL/include/rrtransport.h

		cp -a ${FILESDIR}/usr/share/doc/VirtualGL-2.2.2	/usr/share/doc/
		ln -s /usr/share/doc/VirtualGL-2.2.2	/opt/VirtualGL/doc		
	elif [ "$ARCH" = "i686" ]; then
		einfo "i686 found"
		# cp files/usr/bin/xdm-optimus-32.bin /usr/bin/xdm-optimus
		# dpkg -i install-files/VirtualGL_i386.deb
	fi

	chmod +x /etc/init.d/xdm-optimus
	chmod +x /usr/bin/xdm-optimus

	depmod -a

	# update-alternatives --remove gl_conf /usr/lib/nvidia-current/ld.so.conf
	# rm /etc/alternatives/xorg_extra_modules 
	# ln -s /usr/lib/nvidia-current/xorg /etc/alternatives/xorg_extra_modules-bumblebee

	ldconfig

	# Add nouveau into blacklist
	if [ "`cat /etc/modprobe.d/blacklist.conf |grep "blacklist nouveau" |wc -l`" -eq "0" ]; then
		echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
	fi

	# Add nvidia-current module into modules autoload list
	# if [ "`cat /etc/modules |grep "nvidia-current" |wc -l`" -eq "0" ]; then
	#	echo "nvidia" >> /etc/modules
	# fi

	modprobe -r nouveau
	modprobe nvidia

	INTELBUSID=`echo "PCI:"\`lspci |grep VGA |grep Intel |cut -f1 -d:\`":"\`lspci |grep VGA |grep Intel |cut -f2 -d: |cut -f1 -d.\`":"\`lspci |grep VGA |grep Intel |cut -f2 -d. |cut -f1 -d" "\``
	NVIDIABUSID=`echo "PCI:"\`lspci |grep VGA |grep nVidia |cut -f1 -d:\`":"\`lspci |grep VGA |grep nVidia |cut -f2 -d: |cut -f1 -d.\`":"\`lspci |grep VGA |grep nVidia |cut -f2 -d. |cut -f1 -d" "\``

	echo
	einfo "Changing Configuration to match your Machine"

	sed -i 's/REPLACEWITHBUSID/'$INTELBUSID'/g' /etc/X11/xorg.conf
	sed -i 's/REPLACEWITHBUSID/'$NVIDIABUSID'/g' /etc/X11/xorg.conf.nvidia
	# Setting output device to: $CONNECTEDMONITOR
	sed -i 's/REPLACEWITHCONNECTEDMONITOR/'$CONNECTEDMONITOR'/g' /etc/X11/xorg.conf.nvidia

	echo
	echo
	einfo "Enabling Optimus Service"
	# update-rc.d xdm-optimus defaults
	/etc/init.d/xdm-optimus start

	echo "VGL_DISPLAY=:1" >> /etc/bash/bashrc
	echo "export VGL_DISPLAY" >> /etc/bash/bashrc
	echo "VGL_COMPRESS=$IMAGETRANSPORT" >> /etc/bash/bashrc
	echo "export VGL_COMPRESS" >> /etc/bash/bashrc
	echo "VGL_READBACK=fbo" >> /etc/bash/bashrc
	echo "export VGL_READBACK" >> /etc/bash/bashrc

	if [ "$ARCH" = "x86_64" ]; then
		echo
		echo "64-bit system detected - Configuring"
		echo 
		echo "alias optirun32='vglrun -ld /usr/lib32'
		alias optirun64='vglrun -ld /usr/lib64'" >> /etc/bash/bashrc
	elif [ "$ARCH" = "i686" ]; then
		echo
		echo "32-bit system detected - Configuring"
		echo
		echo "alias optirun='vglrun -ld /usr/lib'" >> /etc/bash/bashrc
	fi

	echo '#!/bin/sh' > /usr/bin/vglclient-service
	echo 'vglclient -gl' >> /usr/bin/vglclient-service
	chmod +x /usr/bin/vglclient-service

	if [ -d $HOME/.kde/Autostart ]; then
		if [ -f $HOME/.kde/Autostart/vlgclient-service ]; then
			rm $HOME/.kde/Autostart/vglclient-service
		fi
		ln -s /usr/bin/vglclient-service $HOME/.kde/Autostart/vglclient-service
	fi

	echo
	echo
	echo "Ok... Installation complete."
	echo
	echo "Now you need to make sure that the command \"vglclient -gl\" is run after your Desktop Enviroment is started"
	echo
	echo "In KDE this is done by this script.. Thanks to Peter Liedler.."
	echo
	echo "In GNOME this is done by placing a shortcut in ~/.config/autostart/ or using the Adminstration->Sessions GUI"
	echo
	if [ "$ARCH" = "x86_64" ]; then
		echo "After that you should be able to start applications with \"optirun32 <application>\" or \"optirun64 <application>\""
		echo "optirun32 can be used for legacy 32-bit applications and Wine Games.. Everything else should work on optirun64"
		echo "But... if one doesn't work... try the other"
	elif [ "$ARCH" = "i686" ]; then
		echo "After that you should be able to start applications with \"optirun <application>\"."
	fi
	echo
	echo "Good luck... MrMEEE / Martin Juhl"
	echo
	echo "http://www.martin-juhl.dk, http://twitter.com/martinjuhl, https://github.com/MrMEEE/bumblebee"
}

pkg_postinst() {
	einfo "<> pkg_postinst()"
}
