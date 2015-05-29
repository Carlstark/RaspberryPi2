### **RTL8723BU Driver for Raspberrypi2**
---
* [Image] 2015-05-05-raspbian-wheezy.img
* [Kernel] linux-3.18.14

#### Build Source
* `./build.sh all <kernelPath>`

Target images are created under directory `install`.

#### **Usage**
---
##### **WIFI**


If there is no `wifi configuration` installed, please install it:

* `apt-get update`
* `apt-get install wpagui`

Load driver modules:

* `modprobe cfg80211`
* `insmod 8723bu.ko`

Check the wifi interface:

* `ifconfig wlan0`

Start wireless networking [Very Important]:

* `/etc/init.d/networking restart`

Launch the `wpa_gui` to configure it:

* Menu -> Run -> fill 'wpa_gui' -> Click 'OK'

---
##### **BLUETOOTH**

Install bluetooth libs and utilities:

* `apt-get install bluetooth bluez-utils blueman rfkill`

Load driver modules:

* `modprobe bluetooth`
* `insmod rtk_btusb.ko`

Enable the bluetooth interface with command line:

* `hciconfig hci0 up`

Check the hardware info:

* `hciconfig hci0`

Launch "Bluetooth Manager":

* Menu -> Preferences -> Bluetooth Manager
* Search -> Pair -> Send File...
