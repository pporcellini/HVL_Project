This repository includes the infrastructure required to build and deploy a hypervisorless virtio environment, based on https://github.com/danmilea/hypervisorless_virtio_zcu102. Check it out for more information.

## How to use

* Download in folder "dl" https://www.xilinx.com/member/forms/download/xef.html?filename=xilinx-zynqmp-common-v2020.2.tar.gz
and https://www.xilinx.com/member/forms/download/xef.html?filename=xilinx-zcu102-v2020.2-final.bsp
* Run "docker build -t hvl_virtio ."
* Run "docker run -v ./out:/home/hypervisorless_virtio_zcu102/hvlws/out --name hvl -it hvl_virtio". Run "docker start -ai hvl" if you shut down the container.
* Inside Docker container run "./build.sh" and "./qemu.sh"
* Open four terminal windows, and in each one run "docker exec -it hvl bash"
* In the first window, run the two commands related to PMU.
* In the second, run the command related to PS, block automatic startup and enter the U-Boot configuration. Wait for Linux to load, log in with username “root” and password “root”, run “cd /hvl” and then “./start.sh”
* In the third, run the command related to Zephyr
* In the fourth, use ssh to log back into the Linux shell on A53 and start the remote core
	
## Changes:

Also check these related repositories to see the changes made:
* https://github.com/pporcellini/hypervisorless_virtio_zcu102
* https://github.com/pporcellini/zephyr/tree/demo-2022-12

	
Dockerfile:
* The entire building and emulation environment has been encapsulated in a single Docker image, which installs dependencies and copies the necessary files inside.

Build Script:
* Several sections have been created to enable/disable the compilation/installation of requirements as needed, allowing for partial builds and speeding up system rebuilds following changes.
* Version v2024.1 of QEMU XILINX is now used, the same as in the official OpenAMP demo image.
* The construction of the sd image has changed; now the make-sd-target script used in the official OpenAMP demo image is used, adding a make-targets-helper specific to the problem.

Zephyr:
* References to the OpenAMP and Libmetal repositories in west.yml have been adjusted, and the code in /samples/virtio/hvl_net_rng_reloc has been instrumented to measure timing.

Demo RPMsg Multi Services:
* The file https://github.com/OpenAMP/openamp-system-reference/blob/v2024.05/examples/linux/rpmsg-utils/rpmsg_ping.c has been modified to measure timimg; it is compiled using Petalinux SDK. Insert the compiled file into the openamp/demo-lite:v2024.05 container, copy it to demo-r5-combo/my-extra-stuff/home/root. Once QEMU has started, run "cp rpmsg_ping /usr/bin/" and start the demo"./demo1"


## build.sh
BUILD_PETALINUX:
    Extracts the files contained in the compressed packages related to the Board Support Package, necessary to obtain the precompiled images, and to the Common Image, used for the installation of the PetaLinux Software Development Kit (SDK).

BUILD_QEMU_XILINX:
    Clones the repository of the QEMU variant developed by Xilinx, configures the installation by enabling aarch64, arm, and microblaze as targets, and installs it in the hvlws/qemu_inst folder.

BUILD_LINUX:
    Clones the Linux repository, sets the configuration provided by OpenAMP, compiles Linux and related modules for the aarch64 architecture

BUILD_DTB:
    Compiles the device tree

BUILD_KVM_MODS:
    Compile modified KVM and the user_mailbox module, copy all files to the destination folder

BUILD_ZEPHYR:
    Install the Zephyr SDK, activate the Python virtual environment, and build Zephyr using west.
	An attempt was made using the latest available version of Zephyr for hypervisor-less VirtIO, also upgrading the SDK, but the build failed.

BUILD_SD:
    Creates the boot and rootfs folders for the two SD partitions, copying all the necessary files to them, installs some utility tools using the chr_setup.sh script with dnf, and runs the make-image-targets script to create the disk image.
