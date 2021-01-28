{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: let
    forEachSystem = func:
      nixpkgs.lib.genAttrs systems func;
    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  in rec {

    packages = forEachSystem (system: {
      bagnoster = with nixpkgs.legacyPackages.x86_64-linux;
        stdenv.mkDerivation rec {
          name = "bagnoster";
          version = if self ? rev then self.rev else "dirty";
          bagnoster = ./bagnoster.bash;
          gitPath = git;
          busyboxPath = busybox;
          builder = builtins.toFile "builder.sh" ''
            source $stdenv/setup
            cat $bagnoster |\
              sed "s,git,$gitPath/bin/git,g;s,id -u,$busyboxPath/bin/id -u,;s,basename,$busyboxPath/bin/basename,g"\
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
