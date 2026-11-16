final: prev: {
  requireFile =
    args:
    if builtins.isAttrs args && (args.hashMode or "flat") == "flat" then
      final.fetchurl (
        {
          inherit (args) name;
          url = "https://fs.jv.ax/chaosbox/nix-files/${args.name}";
        }
        // builtins.intersectAttrs {
          hash = null;
          sha256 = null;
          sha1 = null;
        } args
      )
    else
      prev.requireFile args;
}
