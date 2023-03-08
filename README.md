# openSSH_new_version_Install

This is intllation steps to install openSSH new linux version .

1. Download SERVICES folder and change owner of all files in SERVICES folder. \n
   sudo chown root:root ./SERVICES/*
   Copy content of SERVICES folder into /usr/lib/systemd/system/

2. Download openSSH_opt_install.sh file and change its permition.
   sudo chmod +x ./openSSH_opt_install.sh
   execute ./openSSH_opt_install.sh and follow the steps

   The last version of openSSH follow this link
   https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/

3. There is no needs to uninstall old openSSH version.
   After installation it will be stoped && disabled.

   If you want to check installed openSSH running version
   just type 
   echo | nc localhost 22
   Instead of port 22 use your actual allowed port.  
   
   Original repository is here
   https://gist.github.com/jtmoon79/745e6df63dd14b9f2d17a662179e953a
