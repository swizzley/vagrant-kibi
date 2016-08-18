#!/usr/bin/env bash
case "$1" in
    reinstall)
        case "$2" in
            lite)
                KIBI="kibi-4-4-2-linux-x64-demo-lite-zip"
                ;;
            full)
                KIBI="kibi-4-4-2-linux-x64-demo-full-zip"
                ;;
            *)
                echo "Must specify kibi to restart, options are : [full, lite]"
                exit 1
                ;;
        esac
        if [ -n "$(pgrep -u kibi)" ]; then
            sudo kill -9 $(pgrep -u kibi)
        fi
        sudo rm -rf /opt/kibi
        ;;
    full)
        KIBI="kibi-4-4-2-linux-x64-demo-full-zip"
        ;;
    *)
        KIBI="kibi-4-4-2-linux-x64-demo-lite-zip"
        ;;
esac

if [ "$(ping -c 1 $MY_PRIVATE_REPO)" ]; then
    SRC="$MY_PRIVATE_REPO/x86_64/src/kibi"
    EPEL_BASE="$MY_PRIVATE_REPO/epel/x86_64/7/"
    HQ_PLUGIN="$MY_PRIVATE_REPO/x86_64/src/kibi/elasticsearch-HQ-2.0.3.zip"
else
    SRC="bit.do"
    EPEL_BASE="http://download.fedoraproject.org/pub/epel/7/$basearch"
    HQ_PLUGIN="https://github.com/royrusso/elasticsearch-HQ/archive/v2.0.3.zip"
fi

if [ ! -f "/tmp/$KIBI" ]; then
	sudo curl -kL -o /tmp/$KIBI http://$SRC/$KIBI
fi

if [ ! "$(which node &> /dev/null)" ]; then
    sudo yum makecache fast &> /dev/null
    if [ ! "$(yum repolist all|grep -i epel)" ]; then
        sudo echo "[epel]" > /etc/yum.repos.d/epel.repo
        sudo echo "name=EPEL" >> /etc/yum.repos.d/epel.repo
        sudo echo "baseurl=$EPEL_BASE" >> /etc/yum.repos.d/epel.repo
        sudo echo "gpgcheck=0" >> /etc/yum.repos.d/epel.repo
    fi
    sudo yum -y install nodejs
fi

if [ ! "$(which java &> /dev/null)" ] || [ ! "$(readlink -f $(which java)|grep -q 1.8)" ]; then
    sudo yum -y install java-1.8.0-openjdk
fi

if [ ! "$(which unzip &> /dev/null)" ]; then
    sudo yum -y install unzip
fi

if [ ! "$(id kibi)" ]; then
    echo "adding user kibi"
    sudo useradd -d /opt/kibi -M -s /sbin/nologin kibi
fi

if [ ! -d "/opt/kibi" ]; then
    sudo unzip -q /tmp/$KIBI -d /tmp/archive
    sudo mv /tmp/archive/* /opt/kibi
    sudo rmdir /tmp/archive
    sudo chown -R kibi:kibi /opt/kibi
    sudo sed -i s/'server.host: "localhost"'/'server.host: "0.0.0.0"'/g /opt/kibi/kibi/config/kibi.yml
    sudo sed -i "s#elasticsearch\\.url.*#elasticsearch.url: \"http://$(facter ipaddress):9220\"#g" /opt/kibi/kibi/config/kibi.yml
    sudo sed -i s/'# network.host: 192.168.0.1'/'network.host: _site_'/g /opt/kibi/elasticsearch/config/elasticsearch.yml

fi

sudo /sbin/service firewalld stop

echo "starting elasticsearch"
sudo -u kibi /opt/kibi/elasticsearch/bin/elasticsearch &
until [ -d "/opt/kibi/elasticsearch/logs" ]; do sleep 1; done
until [ "$(grep node /opt/kibi/elasticsearch/logs/*.log|grep started)" ]; do sleep 1; done
sudo /opt/kibi/elasticsearch/bin/plugin install $HQ_PLUGIN
sudo -u kibi /opt/kibi/kibi/bin/kibi 0<&- &>/dev/null &
echo "Kibi running at http://$(facter ipaddress):5606"
echo "Elastic HQ running at http://$(facter ipaddress):9220/_plugin/HQ"
