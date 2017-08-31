#! /bin/sh
find_disks() {
	local p=
	# filter out ramdisks (major=1)
	for p in $(awk '$1 != 1 && $1 ~ /[0-9]+/ {print $4}' /proc/partitions); do
		is_available_disk $p && echo -n " $p"
	done
}

is_available_disk() {
	local dev=$1
	local b=$(echo $p | sed 's:/:!:g')

	# check if its a "root" block device and not a partition
	[ -e /sys/block/$b ] || return 1

	# check so it does not have mounted partitions
	has_mounted_part $dev && return 1

	# check so its not part of an md setup
	if has_holders /sys/block/$b; then
		[ -n "$USE_RAID" ] && echo "Warning: $dev is part of a running raid" >&2
		return 1
	fi

	# check so its not an md device
	[ -e /sys/block/$b/md ] && return 1

	return 0
}

has_holders() {
	local i
	# check if device is used by any md devices
	for i in $1/holders/* $1/*/holders/*; do
		[ -e "$i" ] && return 0
	done
	return 1
}

has_mounted_part() {
	local p
	local sysfsdev=$(echo ${1#/dev/} | sed 's:/:!:g')
	# parse /proc/mounts for mounted devices
	for p in $(awk '$1 ~ /^\/dev\// {gsub("/dev/", "", $1); gsub("/", "!", $1); print $1}' \
			/proc/mounts); do
		[ "$p" = "$sysfsdev" ] && return 0
		[ -e /sys/block/$sysfsdev/$p ] && return 0
	done
	return 1
}

apk update
apk add haveged lvm2 cryptsetup e2fsprogs syslinux sed

rc-service haveged start

# Naive disk handling because I can't be bothered.
DISK="/dev/$(find_disks | awk '{print $1}')"

sfdisk "$DISK" <<EOF
1;+100m;L;*;;
;;8e;;;
EOF

sleep 10

mdev -s

cryptsetup luksFormat "$DISK"2

LVM_NAME="lvmcrypt"
LVM="/dev/mapper/$LVM_NAME"
VG="vg0"
SWAP="/dev/$VG/swap"
ROOT="/dev/$VG/root"
cryptsetup open --type luks "$DISK"2 "$LVM_NAME"
pvcreate "$LVM"
vgcreate "$VG" "$LVM"
lvcreate -L 1G "$VG" -n swap
lvcreate -l "+100%FREE" "$VG" -n root
lvscan
mkfs.ext4 "$ROOT"
mkswap "$SWAP"
mkfs.ext4 "$DISK"1

MOUNT="/mnt/"
BOOT="$MOUNT/boot/"
mount -t ext4 "$ROOT" "$MOUNT"
mkdir "$BOOT"
mount -t ext4 "$DISK"1 "$BOOT"

setup-disk -m sys "$MOUNT"

cat >> "$MOUNT/etc/crypttab" <<EOF
$LVM_NAME ${DISK}2 none luks
EOF

cat >> "$MOUNT/etc/fstab" <<EOF
$SWAP swap swap defaults 0 0 
EOF

sed -i 's/^features="\(.*\)"/features="\1 cryptsetup"/g' "$MOUNT/etc/mkinitfs/mkinitfs.conf"

mkinitfs -c "$MOUNT/etc/mkinitfs/mkinitfs.conf" -b "$MOUNT" $(ls -1 "$MOUNT/lib/modules/")

sed -i 's/^default_kernel_opts="\(.*\)"/default_kernel_opts="\1 cryptroot='"$DISK"2' cryptdm='"$LVM_NAME"'"/g' "$MOUNT/etc/mkinitfs/mkinitfs.conf"

chroot "$MOUNT" update-extlinux

dd bs=440 count=1 conv=notrunc if="$MOUNT/usr/share/syslinux/mbr.bin" of="$DISK"

umount "$BOOT"
umount "$MOUNT"

swapoff -a
vgchange -a n
cryptsetup luksClose "$LVM_NAME"
