# openSSH_new_version_Install

This is intllation steps to install openSSH new version.

1. Download SERVICES folder and change owner of all files in SERVICES folder.
   sudo chown root:root ./SERVICES/*
   Copy content of SERVICES folder into /usr/lib/systemd/system/

2. Download openSSH_opt_install.sh file and change its permition.
   sudo chmod +x ./openSSH_opt_install.sh
   execute ./openSSH_opt_install.sh and follow the steps

   The last version of openSSH follow this link
   https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/
   