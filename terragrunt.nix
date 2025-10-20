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
          # Set TF_DATA_DIR similar to how terragrunt would to it but without stupidity.
          extra_arguments.TF_DATA_DIR = {
            commands = [
              "apply"
              "console"
              "destroy"
              "fmt"
              "force-unlock"
              "get"
              "graph"
              "import"
              "init"
              "login"
              "logout"
              "metadata"
              "output"
              "plan"
              "providers"
              "refresh"
              "show"
              "state"
              "taint"
              "test"
              "untaint"
              "validate"
              "version"
              "workspace"
            ];
            env_vars.TF_DATA_DIR = ''''${get_env("PWD")}/${name}'';
          };
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
      files =
        (lib.mapAttrs' (name: value: {
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
        }) config.units)
        // (lib.mapAttrs' (name: value: {
          name = "${name}/config.tf.json";
          value = builtins.toJSON ((lib.filterAttrs (n: v: v != { })) value.terranix);
        }) config.units);
    };
    # internal.terragruntDir = pkgs.buildEnv {
    #   name = "terragruntDir";
    #   paths = lib.pipe config.units [
    #     lib.attrsToList
    #     (lib.map (
    #       x:
    #       pkgs.writeTextFile {
    #         name = x.name;
    #         text = builtins.toJSON (
    #           lib.pipe x.value [
    #             (
    #               x:
    #               builtins.removeAttrs x [
    #                 "terranix"
    #                 "internal"
    #               ]
    #             )
    #             (lib.filterAttrs (n: v: v != { }))
    #           ]
    #         );
    #         destination = "/${x.name}/terragrunt.hcl.json";
    #       }
    #     ))
    #   ];
    # };
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
          export TG_EXPERIMENT=symlinks
          export TG_NO_AUTO_INIT=true
          ${lib.getExe pkgs.terragrunt} --working-dir=${config.internal.terragruntDir}/$PROJ $@ $ALL
        '';
  };
}
