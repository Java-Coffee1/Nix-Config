{ lib, config, ... }:
# these is a module that let me choose between things when it comes to is GUI and no Gui do not add anything else here.
{
  options.javi = {
    isGui = lib.mkOption {
      type = lib.types.bool;
      # intentionally no default; must be set
    };
  };
}
