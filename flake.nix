{
  description = "A very basic flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs = { self, nixpkgs }: let
    forEachSystem = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in rec {
    packages = forEachSystem (system: {
      bagnoster = with nixpkgs.legacyPackages.${system};
        stdenv.mkDerivation rec {
          name = "bagnoster";
          version = if self ? rev then self.rev else "dirty";
          bagnoster = ./bagnoster.bash;
          gitPath = git;
          coreutilsPath = coreutils;
          builder = builtins.toFile "builder.sh" ''
            source $stdenv/setup
            cat $bagnoster |\
              sed "s,git,$gitPath/bin/git,g;s,id -u,$coreutilsPath/bin/id -u,;s,basename,$coreutilsPath/bin/basename,g"\
              >$out
            chmod 0555 $out
          '';
        };
    });

    defaultPackage = forEachSystem (system:
        packages."${system}".bagnoster
    );

  };
}
