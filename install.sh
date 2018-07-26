#! /bin/bash

# install.sh
# zone installer for pluginadm

#IFS=$'\n'

# initialize random variables...

set -e

# Double Check and make sure the recipe files are in place
if [ `find /opt/.pluginadm/recipes/ -type f -exec basename {} \; | grep -Fxc $1` -ne "1" ]; then
	echo "Error finding recipe files for $1"
	exit 1
fi

# load recipe from source file
source /opt/.pluginadm/recipes/$1

############################################################################
# Generate misc parameters for the json file for vmadm
############################################################################

# Figure out correct brand from $UUID Manifest
case `imgadm get $UUID | json manifest.os` in
	"linux")
		case `imgadm get $UUID | json manifest.type` in
			"zvol")
				BRAND="kvm"
				;;

			"lx-dataset")
				BRAND=`imgadm get $UUID | json manifest.requirements.brand`
				;;
			*)
				echo "Invalid or unexpected manifest for $UUID"
				echo "Run imgadm get $UUID for more info"
				echo "Please not that BSD images are not yet supported"
				exit 1
				;;
		esac
		;;

	"smartos")
		BRAND="joyent"
		;;

	*)
		echo "Invalid or unexpected manifest for $UUID"
		echo "Run imgadm get $UUID for more info"
		echo "Please not that BSD images are not yet supported"
		exit 1
		;;
esac

echo "Brand detected as $BRAND"


# If the Brand is lx, figure out the kernel version
if [ "$BRAND" = "lx" ]; then 
	KERNEL=`imgadm get $UUID | json manifest.tags.kernel_version`
fi

#If any mounted filesystems are required, list them in /temp/$name.fs.json
if [ ${#FILESYSTEMS[@]} = 0 ]; then
	touch /tmp/$name.fs.json
else
	printf "{\n \"filesystems\": [\n" >> /tmp/$name.fs.json
	declare -i n
	n=0
	for FILESYSTEM in ${FILESYSTEMS[@]}; do
		if [ $n -ne 0 ]; then
			printf "," >> /tmp/$name.fs.json
		fi
		cat /opt/.pluginadm/filesystems/$FILESYSTEM.json >> /tmp/$name.fs.json
		((++n))
	done
	printf "]\n}" >> /tmp/$name.fs.json
fi


# Generate json file for vmadm
echo "Creating json file and saving to /tmp/$name.json..."
touch /tmp/$name.json
echo "{}" | json -a --merge -e \
"brand"=\"$BRAND\",\
"image_uuid"=\"$UUID\",\
"alias"=\"$name\",\
"hostname"=\"$name\" \
-f /opt/.pluginadm/default.json >/tmp/$name.json \
`if [ $BRAND = 'lx' ]; then echo "-e kernel_version"=\"$KERNEL\"; fi` \
-f /tmp/$name.fs.json > /tmp/$name.json

rm /tmp/$name.fs.json


echo ""
echo "Please take a moment to review the plugin manifest."
echo "You may have to change some items (such as ip), from their default value."
echo "Any modifications you save to this file will be used to create the zone"
read -p "Press [ENTER] to continue "
echo ""

DONE=false
while [ $DONE = false ]; do
	vim /tmp/$name.json

	read -p "Install Plugin? [Yes/No/Cancel] " ACTION

	case $ACTION in
		y*|Y*)
			DONE=true
			;;

		c|C|Cancel|cancel)
			exit 1
			;;
		n*|N*|*)
			;;
	esac
done

vmadm create -f /tmp/$name.json

zone_uuid=`vmadm list -o create_timestamp,uuid | tail -n +2 | sort | tail -n1 | awk '{print $2}'`

echo $zone_uuid

zone_setup $zone_uuid

post_install_msg $zone_uuid
