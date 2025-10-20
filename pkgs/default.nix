_: pkgs: {
  lib = pkgs.lib.extend (import ../lib);
  writeMultipleFiles = pkgs.callPackage ./writeMultipleFiles.nix { };
}
