#!/bin/sh

MDL_DIR="/lib/modules/$(uname -r)"
DRV_DIR="${MDL_DIR}/kernel/drivers/bluetooth"

cd "$(dirname "$0")"
if [ -f "rtk_btusb.ko" ]; then
	echo "Info: bluetooth drv ..."
	cp -f rtk_btusb.ko $DRV_DIR
	for i in `ls lib/firmware/`; do
		cp -f lib/firmware/$i /lib/firmware/
	done
fi

DRV_DIR="${MDL_DIR}/kernel/net/wireless"
if [ -f "8723bu.ko" ]; then
	echo "Info: wifi drv ..."
	cp -f 8723bu.ko $DRV_DIR
fi

depmod -a $MDL_DIR
if [ $? = 0 ]; then
	echo "Info: install success"
fi
