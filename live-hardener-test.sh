#!/bin/bash

## Copyright (C) 2025 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

set -e
set -o nounset
set -o pipefail
set -o errtrace

base_mount_str='sysfs /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
udev /dev devtmpfs rw,nosuid,relatime,size=16235792k,nr_inodes=4058948,mode=755,inode64 0 0
devpts /dev/pts devpts rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
tmpfs /run tmpfs rw,nosuid,nodev,noexec,relatime,size=3255628k,mode=755,inode64 0 0
efivarfs /sys/firmware/efi/efivars efivarfs rw,nosuid,nodev,noexec,relatime 0 0
securityfs /sys/kernel/security securityfs rw,nosuid,nodev,noexec,relatime 0 0
tmpfs /dev/shm tmpfs rw,nosuid,nodev,inode64 0 0
tmpfs /run/lock tmpfs rw,nosuid,nodev,noexec,relatime,size=5120k,inode64 0 0
cgroup2 /sys/fs/cgroup cgroup2 rw,nosuid,nodev,noexec,relatime,nsdelegate,memory_recursiveprot 0 0
pstore /sys/fs/pstore pstore rw,nosuid,nodev,noexec,relatime 0 0
bpf /sys/fs/bpf bpf rw,nosuid,nodev,noexec,relatime,mode=700 0 0
systemd-1 /proc/sys/fs/binfmt_misc autofs rw,relatime,fd=32,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=10336 0 0
mqueue /dev/mqueue mqueue rw,nosuid,nodev,noexec,relatime 0 0
debugfs /sys/kernel/debug debugfs rw,nosuid,nodev,noexec,relatime 0 0
hugetlbfs /dev/hugepages hugetlbfs rw,nosuid,nodev,relatime,pagesize=2M 0 0
tracefs /sys/kernel/tracing tracefs rw,nosuid,nodev,noexec,relatime 0 0
fusectl /sys/fs/fuse/connections fusectl rw,nosuid,nodev,noexec,relatime 0 0
configfs /sys/kernel/config configfs rw,nosuid,nodev,noexec,relatime 0 0
binfmt_misc /proc/sys/fs/binfmt_misc binfmt_misc rw,nosuid,nodev,noexec,relatime 0 0
tmpfs /run/user/1000 tmpfs rw,nosuid,nodev,relatime,size=3255624k,nr_inodes=813906,mode=700,uid=1000,gid=1000,inode64 0 0
/dev/vda3 /live/image ext4 ro,relatime 0 0
overlay / overlay rw,noatime,lowerdir=/live/image,upperdir=/cow/rw,workdir=/cow/work,default_permissions 0 0
'

base_lsblk_str=' 1
 0
/boot/efi 0
 0
/live/image 0
'

additional_mount_table=(
  '/dev/vda4 /home ext4 rw,relatime 0 0' # 1
  '/dev/sda1 /mnt/drive1 ext4 relatime,rw 0 0
/dev/sda2 /mnt/drive2 ext4 relatime,rw 0 0' # 2
  '/dev/sda1 /mnt/drive1 ext4 relatime,ro 0 0
/dev/sda2 /mnt/drive2 ext4 relatime,rw 0 0' # 3
  '/dev/sda1 /mnt/drive1 ext4 relatime,ro 0 0
/dev/sda2 /mnt/drive2 ext4 relatime,ro 0 0' # 4
  '/dev/sda1 /mnt/drive1 ext4 relatime,rw 0 0
/dev/sdb /mnt/drive2 ext4 relatime,rw 0 0' # 5
  '/dev/sda1 /mnt/drive1 ext4 relatime,rw 0 0
/dev/sdb /mnt/drive2 ext4 relatime,rw 0 0' # 6
  '/dev/sda1 /mnt/drive1 ext4 relatime,rw 0 0
/dev/sdb /mnt/drive2 ext4 relatime,rw 0 0' # 7
  '/dev/nvme0n1p1 /home btrfs rw,noatime,compress=lzo,ssd,discard,autodefrag,subvol=/@home 0 0
/dev/nvme0n1p1 /srv btrfs rw,noatime,compress=lzo,ssd,discard,autodefrag,subvol=/@srv 0 0
/dev/nvme0n1p1 /var btrfs rw,noatime,compress=lzo,ssd,discard,autodefrag,subvol=/@var 0 0' # 8
  '/dev/nvme0n1p1 /home btrfs rw,noatime,compress=lzo,ssd,discard,autodefrag,subvol=/@home 0 0
/dev/nvme0n1p1 /srv btrfs rw,noatime,compress=lzo,ssd,discard,autodefrag,subvol=/@srv 0 0
/dev/nvme0n1p1 /var btrfs rw,noatime,compress=lzo,ssd,discard,autodefrag,subvol=/@var 0 0' # 9
  '/dev/nvme0n1p1 /home btrfs rw,noatime,compress=lzo,ssd,discard,autodefrag,subvol=/@home 0 0
/dev/nvme0n1p1 /srv btrfs ro,noatime,compress=lzo,ssd,discard,autodefrag,subvol=/@srv 0 0
/dev/nvme0n1p1 /var btrfs rw,noatime,compress=lzo,ssd,discard,autodefrag,subvol=/@var 0 0' # 10
  '/dev/sda2 /run/rootfsbase ext4 rw,relatime 0 0' # 11
  '/dev/nvme0n1p1 /var ext4 rw,relatime 0 0
/dev/nvme0n1p2 /var/log ext4 rw,relatime 0 0' # 12
  '/dev/nvme0n1p1 /var ext4 rw,relatime 0 0
/dev/nvme0n1p2 /var/log ext4 rw,relatime 0 0
/dev/nvme0n1p3 /var- ext4 rw,relatime 0 0' # 13
  '/dev/nvme0n1p1 /boot ext4 rw,relatime 0 0
/dev/nvme0n1p2 /boot/whatever ext4 rw,relatime 0 0' # 14
  '/dev/nvme0n1p1 /var ext4 rw,relatime 0 0
/dev/nvme0n1p2 /vara ext4 rw,relatime 0 0' # 15
  '/dev/nvme0n1p1 /boot ext4 rw,relatime 0 0
/dev/nvme0n1p2 /boot/whatever ext4 rw,relatime 0 0
/dev/nvme0n1p3 /bootbackup ext4 rw,relatime 0 0' # 16
)

additional_lsblk_table=(
  '/home 0' # 1
  ' 0
/mnt/drive1 0
/mnt/drive2 0' # 2
  ' 0
/mnt/drive1 0
/mnt/drive2 0' # 3
  ' 0
/mnt/drive1 0
/mnt/drive2 0' # 4
  ' 0
/mnt/drive1 0
/mnt/drive2 1' # 5
  ' 1
/mnt/drive1 1
/mnt/drive2 0' # 6
  ' 1
/mnt/drive1 1
/mnt/drive2 1' # 7
  ' 0
/home\x0a/srv\x0a/var\x0a 0' # 8
  ' 1
/home\x0a/srv\x0a/var\x0a 1' # 9
  ' 0
/home\x0a/srv\x0a/var\x0a 0' # 10
  '/run/rootfsbase 0' # 11
  '/var 0
/var/log 0' # 12
  '/var 0
/var/log 0
/var- 0' # 13
  '/boot 0
/boot/whatever 0' # 14
  '/var 0
/vara 0' # 15
  '/boot 0
/boot/whatever 0
/bootbackup 0' # 16
)

expected_output_table=(
  '/home
/sys/firmware/efi/efivars
/sys/fs/pstore
false
true
false' # 1
  '/mnt/drive1
/mnt/drive2
/sys/firmware/efi/efivars
/sys/fs/pstore
false
false
true
false' # 2
  '/mnt/drive2
/sys/firmware/efi/efivars
/sys/fs/pstore
false
true
false' # 3
  '/sys/firmware/efi/efivars
/sys/fs/pstore
true
false' # 4
  '/mnt/drive1
/sys/firmware/efi/efivars
/sys/fs/pstore
false
true
false' # 5
  '/mnt/drive2
/sys/firmware/efi/efivars
/sys/fs/pstore
false
true
false' # 6
  '/sys/firmware/efi/efivars
/sys/fs/pstore
true
false' # 7
  '/home
/srv
/sys/firmware/efi/efivars
/sys/fs/pstore
/var
false
false
true
false
false' # 8
  '/home
/srv
/sys/firmware/efi/efivars
/sys/fs/pstore
/var
false
false
true
false
false' # 9
  '/home
/sys/firmware/efi/efivars
/sys/fs/pstore
/var
false
true
false
false' # 10
  '/sys/firmware/efi/efivars
/sys/fs/pstore
true
false' # 11
  '/sys/firmware/efi/efivars
/sys/fs/pstore
/var/log
true
false
false' # 12
  '/sys/firmware/efi/efivars
/sys/fs/pstore
/var/log
/var-
true
false
false
false' # 13
  '/boot
/boot/whatever
/sys/firmware/efi/efivars
/sys/fs/pstore
false
true
true
false' # 14
  '/sys/firmware/efi/efivars
/sys/fs/pstore
/var
/vara
true
false
false
false' # 15
  '/boot
/boot/whatever
/bootbackup
/sys/firmware/efi/efivars
/sys/fs/pstore
false
true
false
true
false' # 16
)

kernel_cmdline='BOOT_IMAGE=/boot/vmlinuz-6.1.0-37-amd64 root=/dev/disk/by-uuid/26ada0c0-1165-4098-884d-aafd2220c2c6 ro mitigations=auto,nosmt nosmt=force spectre_v2=on spectre_bhi=on spec_store_bypass_disable=on ssbd=force-on l1tf=full,force kvm-intel.vmentry_l1d_flush=always mds=full,nosmt tsx=off tsx_async_abort=full,nosmt kvm.nx_huge_pages=force l1d_flush=on mmio_stale_data=full,nosmt retbleed=auto,nosmt kvm.mitigate_smt_rsb=1 gather_data_sampling=force reg_file_data_sampling=on slab_nomerge slab_debug=FZ init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on randomize_kstack_offset=on vsyscall=none debugfs=off kfence.sample_interval=100 vdso32=0 efi_pstore.pstore_disable=1 amd_iommu=force_isolation intel_iommu=on iommu=force iommu.passthrough=0 iommu.strict=1 efi=disable_early_pci_dma random.trust_bootloader=off random.trust_cpu=off extra_latent_entropy rootovl boot-role=sysmaint systemd.unit=sysmaint-boot.target loglevel=0 quiet rd.emergency=halt rd.shell=0'
export kernel_cmdline
proc_mount_contents=''
export proc_mount_contents
lsblk_output=''
export lsblk_output
LIVE_HARDENER_TEST='true'
export LIVE_HARDENER_TEST

run_live_hardener_assert() {
  local item_idx additional_mount_entry additional_lsblk_entry expect_str \
    result_str

  item_idx="${1:-}"
  if [ -z "${item_idx}" ]; then
    printf '%s\n' 'No index passed to run_live_hardener_assert!'
    exit 1
  fi
  additional_mount_entry="${additional_mount_table[item_idx]}"
  additional_lsblk_entry="${additional_lsblk_table[item_idx]}"

  proc_mount_contents="${base_mount_str}${additional_mount_entry}"
  lsblk_output="${base_lsblk_str}${additional_lsblk_entry}"
  expect_str=""
  if [ -n "${expected_output_table[item_idx]}" ]; then
    expect_str+="${expected_output_table[item_idx]}"
  fi
  result_str="$(source usr/libexec/grub-live/live-hardener)"

  if [ "${result_str}" != "${expect_str}" ]; then
    printf '%s\n' 'ERROR: Expected:'
    printf '%s\n' "${expect_str}"
    printf '%s\n' 'ERROR: Got:'
    printf '%s\n' "${result_str}"
    printf '%s\n' ''
    return 1
  fi
}

for (( item_idx = 0; item_idx < ${#expected_output_table[@]}; \
  item_idx++ )); do
  if ! run_live_hardener_assert "${item_idx}"; then
    exit 1
  else
    printf '%s\n' "run_live_hardener_assert: Assert $(( item_idx + 1 )) passed."
  fi
done
