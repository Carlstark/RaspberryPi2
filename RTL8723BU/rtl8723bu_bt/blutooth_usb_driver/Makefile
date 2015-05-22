ifneq ($(KERNELRELEASE),)
	obj-m := rtk_btusb.o

else
	PWD := $(shell pwd)
	KVER := 3.18.13
	KDIR := /work/rpi/linux

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules -s

clean:
	rm -rf *.ko *.o *~ core .depend .*.cmd *.mod.c .tmp_versions modules.order  Module.symvers

endif
