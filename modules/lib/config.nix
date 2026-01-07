{ lib, pkgs, ... }:

let
  inherit (lib) escapeShellArg generators getExe;

  toCfg = generators.toINI { };
in

{
  lib.prismlauncher = {
    writeConfigINI = name: value: pkgs.writeText name (toCfg value);

    impureConfigMergerINI =
      filePath: staticSettingsFile: emptySettingsFile:

      ''
        mkdir -p $(dirname ${escapeShellArg filePath})

        if [ ! -e ${escapeShellArg filePath} ]; then
          cat ${escapeShellArg emptySettingsFile} > ${escapeShellArg filePath}
        fi

        ${getExe pkgs.crudini} --merge --ini-options=nospace \
          ${escapeShellArg filePath} < ${escapeShellArg staticSettingsFile}
      '';
  };
}
