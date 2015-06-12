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
    echo "1. copy files under 'install' into rootfs"
	echo "2. sudo ./setup.sh"
    echo "3. apt-get update; apt-get install bluetooth bluez-utils blueman rfkill"
    echo "WIFI:     modprobe cfg80211; insmod 8723bu.ko; ifconfig wlan0"
    echo "BT:       modprobe bluetooth; insmod rtk_btusb.ko"
}

gen_setup() {
	cat << EOF > install/setup.sh
#!/bin/sh
MDL_DIR="/lib/modules/\$(uname -r)"
DRV_DIR="\${MDL_DIR}/kernel/drivers/bluetooth"

cd "\$(dirname "\$0")"
if [ -f "rtk_btusb.ko" ]; then
    echo "Info: bluetooth drv ..."
    cp -f rtk_btusb.ko \$DRV_DIR
    for i in \$(ls lib/firmware/); do
        cp -f lib/firmware/\$i /lib/firmware/
    done
fi

DRV_DIR="\${MDL_DIR}/kernel/net/wireless"
if [ -f "8723bu.ko" ]; then
    echo "Info: wifi drv ..."
    cp -f 8723bu.ko \$DRV_DIR
fi

depmod -a \$MDL_DIR
if [ \$? = 0 ]; then
    echo "Info: install success"
fi
EOF
    chmod a+x install/setup.sh
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
gen_setup
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
