{ ... }:

# ZFS raid0 (stripe) boot for the NAS, split into the classic bpool/rpool
# layout so grub can read a feature-limited "bpool" directly while "rpool"
# holds everything else with the full zfs feature set.
#
# raid0 = capacity/perf, NOT redundancy: if either disk dies, both pools
# (and the whole OS) are gone. That's the deliberate tradeoff here -- this
# box's bulk storage/redundancy lives elsewhere, this is just the OS disk.
#
# Before deploying: replace DISK_1_ID / DISK_2_ID below with the real
# `/dev/disk/by-id/...` paths (check with `ls -l /dev/disk/by-id/` on the
# target machine). disko will wipe whatever these point at.
let
  disk1 = "/dev/disk/by-id/DISK_1_ID";
  disk2 = "/dev/disk/by-id/DISK_2_ID";

  mkDisk = device: {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        biosboot = {
          type = "EF02"; # bios-boot partition, for grub's hybrid BIOS boot
          size = "1M";
          priority = 1;
        };
        ESP = {
          type = "EF00";
          size = "500M";
          priority = 2;
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/efis/${baseNameOf device}";
            mountOptions = [ "umask=0077" ];
          };
        };
        bpool = {
          size = "2G";
          priority = 3;
          content = {
            type = "zfs";
            pool = "bpool";
          };
        };
        rpool = {
          size = "100%";
          priority = 4;
          content = {
            type = "zfs";
            pool = "rpool";
          };
        };
      };
    };
  };
in
{
  disko.devices = {
    disk = {
      disk1 = mkDisk disk1;
      disk2 = mkDisk disk2;
    };

    zpool = {
      # grub-compatible boot pool, striped raid0 across both disks
      bpool = {
        type = "zpool";
        mode = ""; # "" = stripe/raid0; "mirror" would be raid1
        options.ashift = "12";
        # restricts pool features to what grub2 can actually read
        options.compatibility = "grub2";
        rootFsOptions = {
          acltype = "posixacl";
          canmount = "off";
          compression = "lz4";
          devices = "off";
          mountpoint = "none";
          xattr = "sa";
        };
        datasets.boot = {
          type = "zfs_fs";
          mountpoint = "/boot";
          options.mountpoint = "legacy";
        };
      };

      # everything else, also striped raid0 across both disks
      rpool = {
        type = "zpool";
        mode = "";
        options.ashift = "12";
        rootFsOptions = {
          acltype = "posixacl";
          canmount = "off";
          compression = "zstd";
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
          mountpoint = "none";
        };
        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              mountpoint = "legacy";
              atime = "off";
            };
          };
        };
      };
    };
  };

  # grub must be installed on both disks individually -- raid0 striping
  # doesn't give grub a single "boot disk", and the firmware might boot
  # off either one. Both mirroredBoots entries point at the same /boot
  # (the striped bpool above) but each gets its own disk's ESP.
  boot.loader.grub.mirroredBoots = [
    {
      devices = [ disk1 ];
      path = "/boot";
      efiSysMountPoint = "/boot/efis/${baseNameOf disk1}";
    }
    {
      devices = [ disk2 ];
      path = "/boot";
      efiSysMountPoint = "/boot/efis/${baseNameOf disk2}";
    }
  ];
}
