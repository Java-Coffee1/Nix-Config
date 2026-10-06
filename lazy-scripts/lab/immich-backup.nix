{config, ...}:
{
 
  services.borgbackup.jobs."Immich" = {
    paths = config.services.immich.mediaLocation;
    repo = "/homelab/miscellaneous/borg-info/borg-immich";
    startAt = "Sat 04:00";
    compression = "zstd";
    encryption.mode = "none";
    prune.keep = {
      last = 4;
    };
  };

}