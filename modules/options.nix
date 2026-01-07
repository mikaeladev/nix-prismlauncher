{ lib, pkgs, ... }:

let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkOption
    types
    ;

  mkThemeOptions =
    {
      default,
      example,
      themeType,
    }:

    {
      name = mkOption {
        inherit default example;
        type = types.str;
        description = ''
          Name of the selected ${themeType} theme.
        '';
      };

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = ''
          Package providing the ${themeType} theme. Themes can be sourced from
          <https://github.com/PrismLauncher/Themes>. 
        '';
      };
    };
in

{
  options.programs.prismlauncher = {
    enable = mkEnableOption "Prism Launcher";

    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.prismlauncher;
      example = literalExpression "pkgs.prismlauncher";
      description = ''
        Package providing Prism Launcher. This package will be installed to
        your profile. If `null` then Prism Launcher is assumed to already be
        available in your profile.
      '';
    };

    appTheme = mkThemeOptions {
      default = "system";
      example = literalExpression "dark";
      themeType = "application";
    };

    catTheme = mkThemeOptions {
      default = "kitteh";
      example = literalExpression "rory";
      themeType = "cat";
    };

    iconTheme = mkThemeOptions {
      default = "flat";
      example = literalExpression "breeze_light";
      themeType = "icon";
    };

    extraConfig = mkOption {
      type =
        with types;
        attrsOf (oneOf [
          bool
          int
          str
        ]);
      default = { };
      example = {
        ShowConsole = true;
        ConsoleMaxLines = 100000;
      };
      description = ''
        Extra settings for {file}`$XDG_DATA_HOME/PrismLauncher/prismlauncher.cfg`.
      '';
    };
  };
}
