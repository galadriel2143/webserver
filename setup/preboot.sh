#! /bin/sh
CURDIR="$(dirname "$(readlink -f "$0")")"
apk update
apk add haveged lvm2 cryptsetup e2fsprogs syslinux sed sfdisk sgdisk wget ca-certificates

# This is necessary due to a bug.
while [ 1 ] ; do
	mdev -s
	sleep 1
done &
MDEVPID=$!

rc-service haveged start

"$CURDIR/setup-partitions"
"$CURDIR/setup-disk" -m sys -E

cp -r "$CURDIR" /mnt/home/webserver
