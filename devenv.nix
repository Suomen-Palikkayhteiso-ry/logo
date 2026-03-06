{ pkgs, ... }:

{
  profiles.shell.module = {
    packages = [
      pkgs.claude-code
      (pkgs.python3.withPackages (ps: [
        ps.pillow
        ps.cairosvg
      ]))
    ];
  };
}
