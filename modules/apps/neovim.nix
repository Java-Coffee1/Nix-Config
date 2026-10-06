############################################
## Neovim (LSP + completion)
############################################
{ pkgs, ... }:

let
  # `pkgs.neovim.override { configure = ...; }` (the legacy wrapper) always sets
  # $VIMINIT to a generated init.lua, which replaces our own ~/.config/nvim/init.lua
  # instead of loading it. wrapNeovimUnstable with wrapRc = false just puts the
  # plugins on packpath/runtimepath and leaves normal init-file lookup alone.
  nvim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
    wrapRc = false;
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
    ];
  };
in
{
  environment.systemPackages = [
    nvim
    pkgs.nixd # Nix
    pkgs.bash-language-server # Bash/Shell
    pkgs.pyright # Python
    pkgs.lua-language-server # Lua
  ];
}
