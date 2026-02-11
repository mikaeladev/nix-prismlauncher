{ ... }:

{
  projectRootFile = "flake.nix";

  programs.nixfmt = {
    enable = true;
    strict = true;
    width = 80;
    indent = 2;
  };

  programs.mdformat = {
    enable = true;
    settings.wrap = 80;
    plugins = ps: [
      ps.mdformat-gfm
      ps.mdformat-gfm-alerts
    ];
  };
}
