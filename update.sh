#! /bin/bash
# pluginadm update script

set -e

# Fetch latest from repo
echo "Downloading Update..."
wget --no-check-certificate -O /tmp/pluginadm.tar.gz https://github.com/rackmount-everything/pluginadm/archive/master.tar.gz
gtar -xzf /tmp/pluginadm.tar.gz

# Merge default.json
json -f /tmp/pluginadm-master/default.json -f /opt/.pluginadm/default.json --merge > /opt/.pluginadm/default.json
rm /tmp/pluginadm-master/default.json

# Check if there are new filesystems, and if so allow the user to 
NEWFS=`diff /tmp/pluginadm-master/filesystems/  /opt/.pluginadm/filesystems/ | grep "/tmp/" | awk -F '[ ]' '{print $NF}' -`

for FILE in $NEWFS; do
	mv /tmp/pluginadm-master/filesystems/$FILE /opt/.pluginadm/filesystems/$FILE
	echo "NEW CONFIG DETECTED: $FILE"
	echo "Please edit it now to point to the correct directory to the correct dataset on your local machine"
	vim /opt/.pluginadm/filesystems/$FILE
	echo "Thanks, you can edit this later in /opt/.pluginadm/filesystems/$FILE"
done

rm -r /tmp/pluginadm-master/filesystems

# Copy the rest of the files
echo "Installing Remaining Files..."
cp -r /tmp/pluginadm-master/ /opt/.pluginadm/

# Cleanup
rm -r /tmp/pluginadm-master/
rm /tmp/pluginadm.tar.gz
