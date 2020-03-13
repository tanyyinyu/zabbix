bash
#! /bin/bash
while :
  do
    read -p "please make sure you define all the vars, type yes to confirm:" p
    case $p in
    "yes")
      break
      ;;
    *)
      exit
      ;;
    esac
  done
ZABBIX_DB=zabbix_t   #zabbix DB name, to be created;
ZABBIX_IP=192.168.3.16  #zabbix server IP;
ZABBIX_U=zabbix_user    #DB user name;
ZABBIX_PW=zabbix_pw   #DB pw;
SQL_HOST=127.0.0.1   #mysql host IP;
SQL_PORT=3306   #mysql  port;
 #need to change the mysql user:pw;
SQL_LOGIN="mysql -uroot -pFriday28 -h$SQL_HOST -P$SQL_PORT"  
GRANT="grant all on $ZABBIX_DB.* to '$ZABBIX_U'@"$ZABBIX_IP" identified by '$ZABBIX_PW';"
ZABBIX_DIR=/root/zabbix/zabbix_p   #where is the packages;
cd $ZABBIX_DIR
yum localinstall -y apr-1.4.8-5.el7.x86_64.rpm apr-util-1.5.2-6.el7.x86_64.rpm dejavu-fonts-common-2.33-6.el7.noarch.rpm dejavu-sans-fonts-2.33-6.el7.noarch.rpm fontpackages-filesystem-1.44-8.el7.noarch.rpm fping-3.10-4.el7.x86_64.rpm gnutls-3.3.29-9.el7_6.x86_64.rpm httpd-2.4.6-90.el7.centos.x86_64.rpm httpd-tools-2.4.6-90.el7.centos.x86_64.rpm iksemel-1.4-2.el7.centos.x86_64.rpm libevent-2.0.21-4.el7.x86_64.rpm libjpeg-turbo-1.2.90-8.el7.x86_64.rpm libtool-ltdl-2.4.2-22.el7_3.x86_64.rpm libX11-1.6.7-2.el7.x86_64.rpm libX11-common-1.6.7-2.el7.noarch.rpm libXau-1.0.8-2.1.el7.x86_64.rpm libxcb-1.13-1.el7.x86_64.rpm libXpm-3.5.12-1.el7.x86_64.rpm libxslt-1.1.28-5.el7.x86_64.rpm libzip-0.10.1-8.el7.x86_64.rpm mailcap-2.1.41-2.el7.noarch.rpm net-snmp-libs-5.7.2-43.el7_7.3.x86_64.rpm nettle-2.7.1-8.el7.x86_64.rpm OpenIPMI-2.0.27-1.el7.x86_64.rpm OpenIPMI-libs-2.0.27-1.el7.x86_64.rpm OpenIPMI-modalias-2.0.27-1.el7.x86_64.rpm php-5.4.16-46.1.el7_7.x86_64.rpm php-bcmath-5.4.16-46.1.el7_7.x86_64.rpm php-cli-5.4.16-46.1.el7_7.x86_64.rpm php-common-5.4.16-46.1.el7_7.x86_64.rpm php-gd-5.4.16-46.1.el7_7.x86_64.rpm php-ldap-5.4.16-46.1.el7_7.x86_64.rpm php-mbstring-5.4.16-46.1.el7_7.x86_64.rpm php-mysql-5.4.16-46.1.el7_7.x86_64.rpm php-pdo-5.4.16-46.1.el7_7.x86_64.rpm php-xml-5.4.16-46.1.el7_7.x86_64.rpm t1lib-5.1.2-14.el7.x86_64.rpm trousers-0.3.14-2.el7.x86_64.rpm unixODBC-2.3.1-14.el7.x86_64.rpm zabbix-get-4.0.18-1.el7.x86_64.rpm zabbix-server-mysql-4.0.18-1.el7.x86_64.rpm zabbix-web-4.0.18-1.el7.noarch.rpm zabbix-web-mysql-4.0.18-1.el7.noarch.rpm
#mysql
#utf8 is important, it will occur initial problem;
$SQL_LOGIN -e "create database $ZABBIX_DB character set utf8 collate utf8_bin;"
if [ $? != 0 ]
  then
    echo "create database error"
    exit
fi
$SQL_LOGIN -e "$GRANT"
if [ $? != 0 ]
  then
    echo "grant error"
    exit
fi
gzip -d /usr/share/doc/zabbix-server-mysql-4.0.18/create.sql
$SQL_LOGIN $ZABBIX_DB < /usr/share/doc/zabbix-server-mysql-4.0.18/create.sql
sed -i "s/# DBHost=localhost/DBHost=$SQL_HOST/g" /etc/zabbix/zabbix_server.conf
sed -i "s/DBName=zabbix/DBName=$ZABBIX_DB/g" /etc/zabbix/zabbix_server.conf
sed -i "s/DBUser=zabbix/DBUser=$ZABBIX_U/g" /etc/zabbix/zabbix_server.conf
sed -i "s/# DBPassword=/DBPassword=$ZABBIX_PW/g" /etc/zabbix/zabbix_server.conf
sed -i "s/# DBPort=/DBPort=$SQL_PORT/g" /etc/zabbix/zabbix_server.conf
systemctl start httpd
if [ $? != 0 ]
  then
    echo "httpd error"
    exit
fi
systemctl start zabbix-server
if [ $? != 0 ]
  then
    echo "start error"
    exit
fi
echo "if you can not access the zabbix-server IP directory, please connect the IP to a domain name"
echo "please access by [domain|IP]/zabbix with an explorer"
