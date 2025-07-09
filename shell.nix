{ pkgs }:
pkgs.mkShellNoCC {
  name = "home-server";
  meta.description = "Development shell to work on my home-server";
  packages = [
    pkgs.git          # The usual
    pkgs.shellcheck   # Scripting sanity checks
    pkgs.shfmt        # Format shell scripts
  ];
}
