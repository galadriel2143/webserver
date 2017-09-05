#! /bin/sh
CURDIR="$(dirname "$(readlink -f "$0")")"
apk update
apk add haveged lvm2 cryptsetup e2fsprogs syslinux sed sfdisk sgdisk wget ca-certificates

while [ 1 ] ; do
	mdev -s
	sleep 1
done &
MDEVPID=$!

rc-service haveged start

"$CURDIR/setup-partitions"
"$CURDIR/setup-disk" -m sys -E

# TODO Do I need any of this?
#cat >> "$MOUNT/etc/fstab" <<EOF
#$SWAP swap swap defaults 0 0 
#EOF

#sed -i 's/^features="\(.*\)"/features="\1 cryptsetup"/g' "$MOUNT/etc/mkinitfs/mkinitfs.conf"

#mkinitfs -c "$MOUNT/etc/mkinitfs/mkinitfs.conf" -b "$MOUNT" $(ls -1 "$MOUNT/lib/modules/")

#sed -i 's/^default_kernel_opts="\(.*\)"/default_kernel_opts="\1 cryptroot='"$DISK"2' cryptdm='"$LVM_NAME"'"/g' "$MOUNT/etc/mkinitfs/mkinitfs.conf"

#chroot "$MOUNT" update-extlinux

#dd bs=440 count=1 conv=notrunc if="$MOUNT/usr/share/syslinux/mbr.bin" of="$DISK"

#umount "$BOOT"
#umount "$MOUNT"

#swapoff -a
#vgchange -a n
#cryptsetup luksClose "$LVM_NAME"

kill $MDEVPID
