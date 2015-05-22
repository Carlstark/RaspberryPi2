KERNELPATH=""
CROSS="arm-linux-gnueabihf-"

print_usage() {
    echo "Usage:                    -- just for RaspberryPi2[linux-3.18.13] with RTL8723BU"
    echo "$1 all [KERNELPATH]       build wifi & bluetooth modules"
    echo "$1 wifi [KERNELPATH]      build wifi module"
    echo "$1 bt [KERNELPATH]        build bluetooth module"
    echo "$1 clean                  clean target files"
    echo
    echo "==============================================="
    echo "Driver Load Guide:"
    echo "copy files under 'install' into rootfs"
    echo "WIFI:     insmod 8723bu.ko; ifconfig wlan0"
    echo "BT:       modprobe bluetooth; insmod rtk_btusb.ko"
}

build_clean() {
	[ -d "rtl8723bu_wifi" ] && make -C rtl8723bu_wifi clean
	[ -d "rtl8723bu_bt" ] && make -C rtl8723bu_bt/blutooth_usb_driver clean
}

build_distclean() {
	build_clean
	[ -d "install" ] && rm -rf install
}

build_wifi() {
	echo "INFO: Building wifi..."
	if ! [ -d "rtl8723bu_wifi" ]; then
		echo "Error: rtl8723bu_wifi missing"
		exit 1
	fi
	cd rtl8723bu_wifi;
	if [ -z "$KERNELPATH" ]; then
		make CROSS_COMPILE=$CROSS
	else
		make CROSS_COMPILE=$CROSS KSRC=$KERNELPATH
	fi
	! [ $? = 0 ] && exit 1
	cp -f 8723bu.ko ../install/
	! [ $? = 0 ] && exit 1
	cd ->/dev/null
	echo "INFO: wifi buiding done"
}

build_bt() {
	echo "INFO: Building bluetooth..."
	if ! [ -d "rtl8723bu_bt" ]; then
		echo "Error: rtl8723bu_bt missing"
		exit 1
	fi
	cd rtl8723bu_bt
	if [ -z "$KERNELPATH" ]; then
		make -C blutooth_usb_driver
	else
		make -C blutooth_usb_driver KDIR=$KERNELPATH 
	fi
	! [ $? = 0 ] && exit 1
	cp -f blutooth_usb_driver/rtk_btusb.ko ../install

	# firmware
	if ! [ -d "8723B" ]; then
		echo "Error: firmware 8723B missing"
		exit 1
	fi
	dest="../install/lib/firmware/"
	! [ -d "$dest" ] && mkdir -p $dest
	cp -f 8723B/rtl8723b_config $dest/rtl8723bu_config
	cp -f 8723B/rtl8723b_fw $dest/
	cd ->/dev/null
	echo "INFO: bluetooth building done"
}

! [ -d "install" ] && mkdir -p install
! [ -z "$2" ] && KERNELPATH="$2"
case "$1" in
	"clean" )
		build_clean
		;;
	"distclean" )
		build_distclean
		;;
	"all" )
		build_wifi
		build_bt
		;;
	"wifi" )
		build_wifi
		;;
	"bt" )
		build_bt
		;;
	* )
		print_usage $0
		exit 1
		;;
esac
