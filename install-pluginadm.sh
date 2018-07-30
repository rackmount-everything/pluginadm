#!/bin/bash
########## INSTALL
set -e

cd /opt
wget --no-check-certificate https://github.com/rackmount-everything/pluginadm/archive/master.tar.gz

gtar -xzf /opt/master.tar.gz

mv /opt/pluginadm-master/ /opt/.pluginadm

rm /opt/master.tar.gz

cd /opt/.pluginadm/

echo ""
echo "Please take a moment to configure the default settings for your plugins"
echo "You can always change these settings later by editing /opt/.pluginadm/default.json"
echo "[Continue]"
read

vim /opt/.pluginadm/default.json

# Check if dataset exits for plugin data, create if necessary
if [ `zfs list | awk '{print $1}' | grep -c zones/pluginadm` = "0" ]; then
        echo "Creating zones/pluginadm to store plugin data..."
        zfs create zones/pluginadm
        zfs set compression=lz4 zones/pluginadm
fi

# Configure datasets for media, documents, etc.
echo ""
echo "Pluginadm needs to know where you keep media, documents, downloads, etc for certain types of plugins"
echo "You can always change these settings later by editing the files in /opt/.pluginadm/filesystems/"
echo "[Continue]"
read
for FILE in `find /opt/.pluginadm/filesystems/*`; do
        vim $FILE 
done

echo "Setup complete."
