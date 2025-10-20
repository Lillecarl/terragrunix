{
  config,
  pkgs,
  lib,
  ...
}:
let
  jsonType = (pkgs.formats.json { }).type;

  terranixType = lib.types.submodule (
    { ... }:
    {
      options = {
        ephemeral = lib.mkOption {
          type = jsonType;
          default = { };
        };
        data = lib.mkOption {
          type = jsonType;
          default = { };
        };
        locals = lib.mkOption {
          type = jsonType;
          default = { };
          default = { };
        };
        import = lib.mkOption {
          type = jsonType;
          default = { };
        };
        module = lib.mkOption {
          type = jsonType;
          default = { };
        };
        output = lib.mkOption {
          type = jsonType;
          default = { };
        };
        provider = lib.mkOption {
          type = jsonType;
          default = { };
        };
        resource = lib.mkOption {
          type = jsonType;
          default = { };
        };
        terraform = lib.mkOption {
          type = jsonType;
          default = { };
        };
        variable = lib.mkOption {
          type = jsonType;
          default = { };
        };
      };
    }
  );

  unitType = lib.types.submodule (
    {
      name,
      config,
      ...
    }:
    {
      options = {
        terraform = lib.mkOption {
          type = jsonType;
          default = { };
        };
        remote_state = lib.mkOption {
          type = jsonType;
          default = { };
        };
        terranix = lib.mkOption {
          type = terranixType;
          default = { };
        };
        internal = lib.mkOption {
          type = lib.types.anything;
          default = { };
          internal = true;
        };
      };
      config = {
        terraform = {
          # This will never work, we must use Nix for modules
          copy_terraform_lock_file = false;
          # terranix generated config folder
          source = lib.mkDefault (
            pkgs.writeTextFile {
              inherit name;
              text = builtins.toJSON (lib.filterAttrs (n: v: v != { }) config.terranix);
              destination = "/config.tf.json";
            }
          );
        };
      };
    }
  );
in
{
  options = {
    units = lib.mkOption {
      type = lib.types.attrsOf unitType;
      default = { };
    };
    internal = lib.mkOption {
      type = lib.types.anything;
      default = { };
      internal = true;
    };
  };
  config = {
    internal.terragruntDir = pkgs.writeMultipleFiles {
      name = "terragruntDir";
      files = lib.mapAttrs' (name: value: {
        name = "${name}/terragrunt.hcl.json";
        value = builtins.toJSON (
          lib.pipe value [
            (
              x:
              builtins.removeAttrs x [
                "terranix"
                "internal"
              ]
            )
            (lib.filterAttrs (n: v: v != { }))
          ]
        );
      }) config.units;
    };
    internal.script =
      pkgs.writeScriptBin "script" # bash
        ''
          #! ${pkgs.runtimeShell}
          set -x
          PROJ=$1
          ALL=""
          shift
          if test "$PROJ" = "all"; then
            PROJ=""
            ALL="--all"
          fi
          export TG_DOWNLOAD_DIR=$PWD/.terragrunt
          ${lib.getExe pkgs.terragrunt} --working-dir=${config.internal.terragruntDir}/$PROJ $@ $ALL
        '';
  };
}
