{stdenv, git, coreutils}:
stdenv.mkDerivation rec {
    name = "bagnoster";
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
}
