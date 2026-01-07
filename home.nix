{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    escapeShellArg
    getExe
    literalExpression
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.programs.prismlauncher;

  dataDir = "${config.xdg.dataHome}/PrismLauncher";

  iniFormat = pkgs.formats.ini;

  impureConfigMerger =
    filePath: staticSettingsFile: emptySettingsFile:

    ''
      mkdir -p $(dirname ${escapeShellArg filePath})

      if [ ! -e ${escapeShellArg filePath} ]; then
        cat ${escapeShellArg emptySettingsFile} > ${escapeShellArg filePath}
      fi

      ${getExe pkgs.crudini} --merge --ini-options=nospace \
        ${escapeShellArg filePath} < ${escapeShellArg staticSettingsFile}
    '';
in

{
  options.programs.prismlauncher = {
    enable = mkEnableOption "Prism Launcher";

    package = mkPackageOption pkgs "prismlauncher" { nullable = true; };

    icons = mkOption {
      type = types.listOf types.path;
      default = [ ];
      example = literalExpression "[ ./java.png ]";
      description = ''
        List of paths to icon files used for instances. These will be linked
        in {file}`$XDG_DATA_HOME/PrismLauncher/icons`.
      '';
    };

    theme = {
      icons = mkOption {
        type = types.str;
        default = "flat";
        example = literalExpression "breeze_light";
        description = ''
          Name of the selected icon theme. Additional themes can be sourced
          from <https://github.com/PrismLauncher/Themes>.
        '';
      };

      widgets = mkOption {
        type = types.str;
        default = "system";
        example = literalExpression "dark";
        description = ''
          Name of the selected widget theme. Additional themes can be sourced
          from <https://github.com/PrismLauncher/Themes>.
        '';
      };

      cat = mkOption {
        type = types.str;
        default = "kitteh";
        example = literalExpression "rory";
        description = ''
          Name of the selected cat theme. Additional themes can be sourced from
          <https://github.com/PrismLauncher/Themes>.
        '';
      };
    };

    extraConfig = mkOption {
      type = iniFormat.type;
      default = { };
      example = {
        ShowConsole = true;
        ConsoleMaxLines = 100000;
      };
      description = ''
        Extra config for {file}`$XDG_DATA_HOME/PrismLauncher/prismlauncher.cfg`.
      '';
    };

    finalConfig = mkOption {
      type = iniFormat.type;
      default = { };
      visible = false;
      internal = true;
    };
  };

  config = mkIf cfg.enable {
    programs.prismlauncher.finalConfig.General = mkMerge [
      (mkIf (cfg.icons != [ ]) { IconsDir = mkDefault "${dataDir}/icons"; })

      (with cfg.theme; {
        IconTheme = icons;
        ApplicationTheme = widgets;
        BackgroundCat = cat;
      })

      cfg.extraConfig
    ];

    home.packages = mkIf (cfg.package != null) [ cfg.package ];

    home.activation = {
      prismlauncherConfigActivation = (
        lib.hm.dag.entryAfter [ "linkGeneration" ] (
          impureConfigMerger "${dataDir}/prismlauncher.cfg"
            (iniFormat.generate "prismlauncher-static.cfg" cfg.finalConfig)
            (iniFormat.generate "prismlauncher-empty.cfg" { General = { }; })
        )
      );
    };

    xdg.dataFile = mkMerge [
      (mkIf (cfg.icons != [ ]) (
        map (source: {
          "${cfg.finalConfig.General.IconsDir}/${baseNameOf source}" = {
            inherit source;
          };
        }) cfg.icons
      ))
    ];
  };
}
