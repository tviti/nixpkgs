{lib, stdenv, fetchurl, ocaml, zlib, which, eprover, makeWrapper, coq}:
stdenv.mkDerivation rec {
  pname = "satallax";
  version = "2.7";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ocaml zlib which eprover coq];
  src = fetchurl {
    url = "https://www.ps.uni-saarland.de/~cebrown/satallax/downloads/${pname}-${version}.tar.gz";
    sha256 = "1kvxn8mc35igk4vigi5cp7w3wpxk2z3bgwllfm4n3h2jfs0vkpib";
  };

  patches = [
    # GCC9 doesn't allow default value in friend declaration.
    ./fix-declaration-gcc9.patch
  ];

  preConfigure = ''
    mkdir fake-tools
    echo "echo 'Nix-build-host.localdomain'" > fake-tools/hostname
    chmod a+x fake-tools/hostname
    export PATH="$PATH:$PWD/fake-tools"

    (
      cd picosat-*
      ./configure
      make
    )
    export PATH="$PATH:$PWD/libexec/satallax"

    mkdir -p "$out/libexec/satallax"
    cp picosat-*/picosat picosat-*/picomus "$out/libexec/satallax"

    (
      cd minisat
      export MROOT=$PWD
      cd core
      make
      cd ../simp
      make
    )
  '';

  postBuild = "echo testing; ! (bash ./test | grep ERROR)";

  installPhase = ''
    mkdir -p "$out/share/doc/satallax" "$out/bin" "$out/lib" "$out/lib/satallax"
    cp bin/satallax.opt "$out/bin/satallax"
    wrapProgram "$out/bin/satallax" \
      --suffix PATH : "${lib.makeBinPath [ coq eprover ]}:$out/libexec/satallax" \
      --add-flags "-M" --add-flags "$out/lib/satallax/modes"

    cp LICENSE README "$out/share/doc/satallax"

    cp bin/*.so "$out/lib"

    cp -r modes "$out/lib/satallax/"
    cp -r problems "$out/lib/satallax/"
    cp -r coq* "$out/lib/satallax/"
  '';

  meta = {
    inherit version;
    description = "Automated theorem prover for higher-order logic";
    license = lib.licenses.mit ;
    maintainers = [lib.maintainers.raskin];
    platforms = lib.platforms.linux;
    downloadPage = "http://www.ps.uni-saarland.de/~cebrown/satallax/downloads.php";
    homepage = "http://www.ps.uni-saarland.de/~cebrown/satallax/index.php";
    updateWalker = true;
  };
}
