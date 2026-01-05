{ lib, pkgs, ... }:

let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkOption
    types
    ;
in

{
  options.programs.prismlauncher = {
    enable = mkEnableOption "Whether to enable Prism Launcher";

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
  };
}
