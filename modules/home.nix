{ config, lib, ... }:

let
  inherit (lib) mkIf;

  cfg = config.programs.prismlauncher;
in

{
  imports = [ ./options.nix ];

  config = mkIf cfg.enable {
    home.packages = mkIf (cfg.package != null) [ cfg.package ];
  };
}
