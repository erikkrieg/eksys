# Darwin-specific guibox user configuration via home-manager.
# https://nix-community.github.io/home-manager/options.html
{ unstable_pkgs, ... }: {
  home.packages = [
    unstable_pkgs.claude-code
    (unstable_pkgs.proton-drive-cli.overrideAttrs (oldAttrs: {
      # Upstream pins Bun 1.4.2, but this nixpkgs revision supplies 1.4.4.
      postPatch = (oldAttrs.postPatch or "") + ''
        substituteInPlace package.json \
          --replace-fail '"bun": "1.4.2"' '"bun": "${unstable_pkgs.bun.version}"'
      '';
    }))
  ];
}
