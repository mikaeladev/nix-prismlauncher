{ config, lib, ... }:

let
  inherit (lib) mkIf;

  cfg = config.programs.prismlauncher;
in

{
  imports = [ ./options.nix ];

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf (cfg.package != null) [ cfg.package ];
  };
}
