ifneq ($(KERNELRELEASE),)
	obj-m := rtk_btusb.o
	rtk_btusb-y = rtk_coex.o rtk_bt.o
else
	PWD := $(shell pwd)
	KVER := $(shell uname -r)
	KDIR := /lib/modules/$(KVER)/build

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules -s

clean:
	rm -rf *.ko *.o *~ core .depend .*.cmd *.mod.c .tmp_versions modules.order  Module.symvers

endif
