{stdenv, git, busybox}:
stdenv.mkDerivation rec {
    name = "bagnoster";
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
}
