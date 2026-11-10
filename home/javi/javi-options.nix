{ lib, ... }:
# these is a module that let me choose between things when it comes to is GUI and no Gui do not add anything else here.
{
  options.javi = {
    isGui = lib.mkOption {
      type = lib.types.bool;
      # intentionally no default; must be set
    };
  };

  options.homelab.path = {
    data = lib.mkOption {
      type = lib.types.path;
      default = "/homelab";
      description = "Root for homelab service state.";
    };

    nfs = lib.mkOption {
      type = lib.types.path;
      default = "/homelab/nfs";
      description = "Root of the NFS mounts.";
    };
  };
}
