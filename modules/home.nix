{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (config.lib.prismlauncher) impureConfigMergerINI writeConfigINI;

  cfg = config.programs.prismlauncher;

  finalConfig = with cfg; {
    General = extraConfig;
  };

  emptyConfig = {
    General = { };
  };
in

{
  imports = [
    ./lib
    ./options.nix
  ];

  config = mkIf cfg.enable {
    home.packages = mkIf (cfg.package != null) [ cfg.package ];

    home.activation = mkIf (finalConfig != { }) {
      prismlauncherConfigActivation = (
        lib.hm.dag.entryAfter [ "linkGeneration" ] (
          impureConfigMergerINI "${config.xdg.dataHome}/PrismLauncher/prismlauncher.cfg"
            (writeConfigINI "prismlauncher-static.cfg" finalConfig)
            (writeConfigINI "prismlauncher-empty.cfg" emptyConfig)
        )
      );
    };
  };
}
