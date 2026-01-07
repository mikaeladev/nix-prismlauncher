{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (config.lib.prismlauncher) impureConfigMergerINI writeConfigINI;

  cfg = config.programs.prismlauncher;

  finalConfig = with cfg; {
    General = {
      ApplicationTheme = cfg.appTheme.name;
      BackgroundCat = cfg.catTheme.name;
      IconTheme = cfg.iconTheme.name;
    }
    // extraConfig;
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
    home.packages = builtins.concatLists [
      (if cfg.package != null then [ cfg.package ] else [ ])
      (if cfg.appTheme.package != null then [ cfg.appTheme.package ] else [ ])
      (if cfg.catTheme.package != null then [ cfg.catTheme.package ] else [ ])
      (if cfg.iconTheme.package != null then [ cfg.iconTheme.package ] else [ ])
    ];

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
