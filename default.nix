{
  pkgs ? import <nixpkgs> { },
  modules ? [ ./demo ],
  specialArgs ? { },
  debug ? true,
}:
let
  pkgs' = pkgs.extend (import ./pkgs/default.nix);
in
let
  pkgs = pkgs';
  lib = pkgs.lib;
  attrIf = condition: content: if condition then content else { };

  eval = lib.evalModules {
    modules = [
      ./terragrunt.nix
    ]
    ++ modules;
    specialArgs = {
      inherit pkgs;
      inherit (pkgs) lib;
    }
    // specialArgs;
  };
in
{
}
# Add debug attributes if debug is set
// (attrIf debug {
  inherit pkgs lib eval;
})
