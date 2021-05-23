#!/bin/bash
# JohnFordTV's PPTP Premium Script
# © Github.com/johndesu090
# Official Repository: https://github.com/johndesu090/
# For Updates, Suggestions, and Bug Reports, Join to my Messenger Groupchat(VPS Owners): https://m.me/join/AbbHxIHfrY9SmoBO
# For Donations, Im accepting prepaid loads or GCash transactions:
# Smart: 09206200840
# Facebook: https://fb.me/johndesu090
# Thanks for using this script

#############################
#############################
# Variables (Can be changed depends on your preferred values)

# Script name
MyScriptName='JohnFordTV-PPTP Server'

# Server local time
MyVPS_Time='Asia/Manila'

#############################

function InstUpdates(){
 export DEBIAN_FRONTEND=noninteractive
 apt-get update
 apt-get upgrade -y
 
 # Removing some firewall tools that may affect other services
 apt-get remove --purge ufw firewalld -y

 
 # Installing some important machine essentials
 apt-get install nano wget curl zip unzip tar gzip p7zip-full bc rc openssl cron net-tools dnsutils dos2unix screen bzip2 ccrypt -y
 
 # Now installing all our wanted services
 apt-get install gnupg tcpdump grepcidr dropbear screen privoxy ca-certificates apt-transport-https lsb-release -y

 # Installing all required packages to install Webmin
 apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python dbus libxml-parser-perl -y
 # Update SSL Libraries
 sudo update-ca-certificates --fresh
 export SSL_CERT_DIR=/etc/ssl/certs
}

function InstPPTP(){

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

echo
echo "Creating backup..."
$DIR/backup.sh

echo
echo "Installing PPTP server..."
eval $PCKTMANAGER update
if [ "$PLATFORM" == "$CENTOSPLATFORM" ]; then
	eval $INSTALLER epel-release
fi
eval $INSTALLER ppp pptpd $CRON_PACKAGE $IPTABLES_PACKAGE procps net-tools

ADDUSER="no"
ANSUSER="yes"

echo
echo "Configuring iptables firewall..."
$DIR/iptables-setup.sh

echo
echo "Configuring routing..."
$DIR/sysctl.sh

echo
echo "Installing configuration files for PPTP..."
yes | cp -rf $DIR/options.pptp.dist $PPTPOPTIONS
yes | cp -rf $DIR/pptpd.conf.dist $PPTPDCONFIG

sed -i -e "s@PPTPOPTIONS@$PPTPOPTIONS@g" $PPTPDCONFIG
sed -i -e "s@LOCALPREFIX@$LOCALPREFIX@g" $PPTPDCONFIG

echo
echo "Configuring DNS parameters..."
$DIR/dns.sh

echo
echo "Adding cron jobs..."
yes | cp -rf $DIR/checkserver.sh $CHECKSERVER
$DIR/autostart.sh

echo
echo "Configuring VPN users..."
$DIR/adduser.sh

echo
echo "Starting pptpd..."
service pptpd restart
systemctl enable pptpd

}

function ConfMenu(){
echo -e " Creating Menu scripts.."

cd /usr/local/sbin/
rm -rf {accounts,base-ports,base-ports-wc,base-script,bench-network,clearcache,connections,create,create_random,create_trial,delete_expired,diagnose,edit_dropbear,edit_openssh,edit_openvpn,edit_ports,edit_squid3,edit_stunnel4,locked_list,menu,options,ram,reboot_sys,reboot_sys_auto,restart_services,server,set_multilogin_autokill,set_multilogin_autokill_lib,show_ports,speedtest,user_delete,user_details,user_details_lib,user_extend,user_list,user_lock,user_unlock}
wget -q 'https://www.dropbox.com/s/cfhixrijgtefwza/pptpmenu.zip'
unzip -qq pptpmenu.zip
rm -f pptpmenu.zip
chmod +x ./*
dos2unix ./* &> /dev/null
cd ~
}

function ScriptMessage(){
 echo -e " [\e[1;32m$MyScriptName\e[0m]"
 echo -e ""
 echo -e " https://fb.com/johndesu090"
 echo -e "[GCASH] 09206200840 [PAYONEER] admin@johnfordtv.tech"
 echo -e ""
}

#############################################
#############################################
########## Installation Process##############
#############################################
## WARNING: Do not modify or edit anything
## if you did'nt know what to do.
## This part is too sensitive.
#############################################
#############################################

 # Begin Installation by Updating and Upgrading machine and then Installing all our wanted packages/services to be install.
 ScriptMessage
 sleep 5
 InstUpdates
 
 # Configure OpenSSH and Dropbear
 echo -e "Configuring PPTPD Server..."
 InstPPTP
 
 # VPS Menu script v1.0
 ConfMenu
 
 # Setting server local time
 ln -fs /usr/share/zoneinfo/$MyVPS_Time /etc/localtime
 
 clear
 cd ~
 
echo 'echo -e ""' >> .bashrc
echo 'echo -e "     ========================================================="' >> .bashrc
echo 'echo -e "     *                  WELCOME TO VPS SERVER                *"' >> .bashrc
echo 'echo -e "     ========================================================="' >> .bashrc
echo 'echo -e "     *                 Autoscript By JohnFordTV              *"' >> .bashrc
echo 'echo -e "     *                   Debian 9 & Debian 10                *"' >> .bashrc
echo 'echo -e "     *                  Facebook: johndesu090                *"' >> .bashrc
echo 'echo -e "     ========================================================="' >> .bashrc
echo 'echo -e "     *     Type \033[1;32mmenu\033[0m to enter commands      *"' >> .bashrc
echo 'echo -e "     ========================================================="' >> .bashrc
echo 'echo -e ""' >> .bashrc
echo 'iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o ens3 -j MASQUERADE' >> .bashrc
echo 'iptables -A FORWARD -p tcp --syn -s 172.16.0.0/24 -j TCPMSS --set-mss 1356' >> .bashrc

 
 # Showing script's banner message
 ScriptMessage
 sleep 8
 
  # Showing additional information from installating this script
echo " "
echo "The server is 100% installed. Please read the server rules and reboot your VPS!"
echo " "
echo "--------------------------------------------------------------------------------"
echo "*                            Debian Premium Script                             *"
echo "*                                 -JohnFordTV-                                 *"
echo "--------------------------------------------------------------------------------"
echo ""  | tee -a log-install.txt
echo "---------------"  | tee -a log-install.txt
echo "Server Information"  | tee -a log-install.txt
echo "---------------"  | tee -a log-install.txt
echo "   - Timezone    : Asia/Manila (GMT +8)"  | tee -a log-install.txt
echo "   - IPtables    : [ON]"  | tee -a log-install.txt
echo "   - Auto-Reboot : [OFF]"  | tee -a log-install.txt
echo "   - IPv6        : [OFF]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "---------------------------"  | tee -a log-install.txt
echo "Application and Port Information"  | tee -a log-install.txt
echo "---------------------------"  | tee -a log-install.txt
echo "   - PPTP		: 1723 "  | tee -a log-install.txt
echo "   - GRE		: 47"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "-----------------------"  | tee -a log-install.txt
echo "Premium Script Information"  | tee -a log-install.txt
echo "-----------------------"  | tee -a log-install.txt
echo "To display the menu list, please type: menu"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo " ©JohnFordTV"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "---------------------------- REBOOT YOUR VPS! -----------------------------"

 # Clearing all logs from installation
rm -rf /root/.bash_history && history -c && echo '' > /var/log/syslog
