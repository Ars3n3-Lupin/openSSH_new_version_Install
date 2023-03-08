#!/bin/bash
# Installation folder
# /opt/openssh-
#
#
clear

# Colors ==============
# Style - backgroud - Forground
Magenta="echo -e \033[3;00;35m"
Blue="echo -e \033[3;00;36m"
ENDS="\033[0m"
# =====================
# Functions ==========
countdown(){
    i=${1-$cdNum}
    while [ "$i" -ge 1 ]; do
    printf '\r%s ' "$i"
    i=`expr $i - 1`
    sleep 1
    done
}
# =====================
echo ""
$Blue"
********************************************************************************
+                   This is an openSSH installation file                       +
+                                                                              +
+   0. Copy four files from SERVICES folder to /usr/lib/systemd/system/        +
+   1. First, a system update && upgrade                                       +
+   2. Second, installation dependencies                                       +
+   3. Third, compiling and install new version openSSH /opt                   +
+   4. Fourth, start ssh-latest.service                                        +
+                                                                              +
********************************************************************************
"$ENDS
echo ""
echo ""

anew=yes
while [ "$anew" = yes ]; do
    anew=no

	prompt='Enter your choice, please: '
	options=("Update && upgrade a system"
			"Install dependances"
			"Install openSSH-server && openSSH-client"
			"Create ssh.service file"
			"Start ssh-latest.service")
	PS3="$prompt"

	select opt in "${options[@]}" "Quit";
	do
	case "$REPLY" in
	"1") 
		clear
$Magenta"
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+      The system is going to be updated && upgraded       +
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"$ENDS
		sleep 2
		sudo apt-get update && sudo apt full-upgrade -y && sudo autoremove -y
$Magenta"System was successfully updated."$ENDS
		anew=yes
		sleep 3
		clear
		break
	;;
	"2")
		clear
$Magenta"
++++++++++++++++++++++++++++++++++++++++++++++++++
+             Installing dependances             +
++++++++++++++++++++++++++++++++++++++++++++++++++
"$ENDS
		sleep 2
		sudo apt install libssl-dev \
				gcc \
				g++ \
				gdb \
				cpp -y
		sudo apt install make \
						cmake \
						libtool \
						libc6 \
						autoconf \
						automake \
						pkg-config \
						build-essential \
						gettext -y
		sudo apt install libzstd1 \
						zlib1g \
						libssh-4 \
						libssh-dev \
						libc6-dev \
						libc6 \
						libcrypt-dev -y
		sudo apt install netcat lsof
$Magenta"Dependances are successfully installed."$ENDS
		anew=yes
		sleep 3
		clear
		break
	;;
	"3") 
		clear
$Magenta"
++++++++++++++++++++++++++++++++++++++++++++++++++
+       Add an openSSH vesrion and install       +
++++++++++++++++++++++++++++++++++++++++++++++++++
"$ENDS

$Magenta"Enter an openSSH version e.g. 9.2p1 : " $ENDS
		read VER
		echo openssh-${VER}

		sudo mkdir /opt/openssh-${VER}
		cd /opt/openssh-${VER}

$Magenta"This is your home directory." $ENDS && pwd && echo ""
sleep 3

		sudo wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${VER}.tar.gz
		# tar -z filter the archive through gzip -x extract 
		# -v verbosely list files processed -f archive file
		sudo tar -zxf openssh-${VER}.tar.gz

		sudo rm -rf /opt/openssh-${VER}/openssh-${VER}.tar.gz

		cd /opt/openssh-${VER}/openssh-${VER}
		pwd
sleep 3
$Magenta "OpenSSH is going to be compiled." $ENDS
sleep 3
		sudo ./configure --prefix=/opt/openssh-${VER} --sysconfdir=/etc/ssh
		sudo make
		sudo make install
sleep 5
		sudo ln -fvs /opt/openssh-${VER} /opt/openssh-latest
		sudo ln -fvs /opt/openssh-latest /etc/ssh-latest
		clear
$Magenta "Successfully installed" $ENDS
		sudo install -v -m700 -d /var/lib/sshd
		sudo chown -v root:sys /var/lib/sshd
		sudo groupadd sshd
		sudo useradd  -c 'sshd PrivSep' -d /var/lib/sshd -g sshd -s /bin/false -u 50 sshd
		sleep 3
		anew=yes
		clear
		break
	;;
	"4")
		clear
$Magenta"
++++++++++++++++++++++++++++++++++++++++++++++++++
+           Creating ssh.service file            +
++++++++++++++++++++++++++++++++++++++++++++++++++
"$ENDS
		sleep 3
		FILE=~/services
		if [[ -e "$FILE" ]]; then
			sleep 2
			sudo rm -rf ~/services
		else
			sleep 2
			mkdir $FILE
			cd $FILE
		fi

# ===========================================>

FILE01=ssh-latest@.service

sudo touch ./${FILE01}
sudo chown root:root ${FILE01}
sudo chmod 646 ${FILE01}

cat > ./${FILE01} <<EOF
[Unit]
Description=OpenBSD Secure Shell server per-connection daemon
Documentation=man:sshd(8) man:sshd_config(5)
After=auditd.service

[Service]
EnvironmentFile=-/opt/openssh-latest/default/ssh
ExecStart=/opt/openssh-latest/sbin/sshd -i $SSHD_OPTS
StandardInput=socket
RuntimeDirectory=sshd-latest
RuntimeDirectoryMode=0755
EOF
sudo chmod 644 ${FILE01}

# ===========================================>

FILE02=ssh-latest.socket

sudo touch ./${FILE02}
sudo chown root:root ${FILE02}
sudo chmod 646 ${FILE02}

cat > ./${FILE02} <<EOF
[Unit]
Description=OpenBSD Secure Shell server socket
Before=ssh-latest.service
Conflicts=ssh-latest.service
ConditionPathExists=!/opt/openssh-latest/etc/sshd_not_to_be_r

[Socket]
ListenStream=2222
Accept=yes

[Install]
WantedBy=sockets.target
EOF
sudo chmod 644 ${FILE02}

# ===========================================>

FILE03=ssh-latest.service

sudo touch ./${FILE03}
sudo chown root:root ${FILE03}
sudo chmod 646 ${FILE03}

cat > ./${FILE03} <<EOF
[Unit]
Description=OpenBSD Secure Shell server
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target auditd.service
ConditionPathExists=!/opt/openssh-latest/etc/sshd_not_to_be_r

[Service]
EnvironmentFile=-/opt/openssh-latest/default/ssh
ExecStartPre=/opt/openssh-latest/sbin/sshd -t
ExecStart=/opt/openssh-latest/sbin/sshd -D $SSHD_OPTS
ExecReload=/opt/openssh-latest/sbin/sshd -t
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartPreventExitStatus=255
Type=exec
RuntimeDirectory=sshd-latest
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target
Alias=sshd-latest.service
EOF
sudo chmod 644 ${FILE03}

# ===========================================>

FILE04=rescue-ssh-latest.target

sudo touch ./${FILE04}
sudo chown root:root ${FILE04}
sudo chmod 646 ${FILE04}

cat > ./${FILE04} <<EOF
[Unit]
Description=Rescue with network and ssh
Documentation=man:systemd.special(7)
Requires=network-online.target ssh-latest.service
After=network-online.target ssh-latest.service
AllowIsolate=yes
EOF
sudo chmod 644 ${FILE04}

		sudo cp $FILE/* /usr/lib/systemd/system

		sudo rm -rf $FILE

		sleep 3

$Magenta " 
********************************************************************************************
+   Data were added to /lib/systemd/system/. Now, enable and start ssh.service manually.   +
+                                                                                          +
+   1. sudo systemctl enable /etc/systemd/system/ssh.service                               +
+   2. sudo systemctl start /etc/systemd/system/ssh.service                                +
+   3. sudo systemctl status ssh                                                           +
+                                                                                          +
********************************************************************************************
"$ENDS

		countdown 5
		
		anew=yes
		clear
		break
	;;
	"5") 
		clear
$Magenta"
++++++++++++++++++++++++++++++++++++++++++++++++++
+            Start SSH-latest.service            +
++++++++++++++++++++++++++++++++++++++++++++++++++
"$ENDS
		sleep 3
		sudo systemctl enable ssh-latest.service
		sudo systemctl enable ssh-latest.socket
		sudo systemctl daemon-reload
		sudo systemctl start ssh-latest.service
		sudo systemctl start ssh-latest.socket
		sudo systemctl stop ssh.service
		sudo systemctl stop ssh.socket
		sudo systemctl disable ssh.service
		sudo systemctl disable ssh.socket
		sudo systemctl daemon-reload
		clear
		sudo systemctl status ssh.service
		sleep 3
		clear
		anew=yes
		clear
		break
	;;
		$((${#options[@]}+1))) echo "Goodbye!"; 
		break;;
		*) echo "invalid option $REPLY"; 
		continue;;
		esac
	done
done
