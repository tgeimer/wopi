# WOPi

## **W**ildlife **O**bservation **Pi**

WOPi is a software bundle to turn your Raspberry Pi into a multi-purpose wildlife observation platform.
> Raspberry Pi is a trademark of the Raspberry Pi Foundation.

##Features##
* Make use of the Raspberry Pi camera module to upload a picture to the web in a predefined interval
* attach one or more (DS1820) temperature sensors to your pi and collect their data
* convenient browser based web administration instead of CLI

Use your **WOPi** to:
* watch what's going on in the birdbox in your garden (my current use case)
* remotely observe your aquarium 
* check on the stats of your lizard's terrarium
* install a wildlife cam somewhere else
* ...

I want everybody to be able to realize a wildlife observation project without the need of having to dive into the depths of the technical realization - including having to administer the Pi via CLI over an ssh connection to install and configure the necessary software. This is how WOPi came to be. One install script is everything a "non-technical" user should have to invoke to have a fully running Wildlife Observation Platform.

##Installation##
The installation procedure described here assumes that you use a current Raspbian image. Here are the steps to get WOPi up and running.
Log in to your pi as user ```pi```. You are in your home directory. A default WOPi installation assumes all WOPi related files to reside there.

* get the contents of this repository:
```shell
git clone https://github.com/tgeimer/wopi.git wopi
```
* make the install script executable:
```shell
chmod a+x wopi/install.sh
```
* execute the installation script with root privileges:
```shell
sudo wopi/install.sh
```
* wait until everything has installed and check the installation log:
```shell
cat wopi/log/install.log
```

Check back soon to see the progress.
