{ lib, stdenv, fetchFromGitHub, makeWrapper, imagemagick, xorg }:

stdenv.mkDerivation rec {
  pname = "ttygif";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "icholy";
    repo = pname;
    rev = version;
    sha256 = "1w9c3h6hik2gglwsw8ww63piy66i4zqr3273wh5rc9r2awiwh643";
  };

  makeFlags = [ "CC:=$(CC)" "PREFIX=${placeholder "out"}" ];

  nativeBuildInputs = [ makeWrapper ];
  postInstall = ''
    wrapProgram $out/bin/ttygif \
      --prefix PATH : ${lib.makeBinPath [ imagemagick xorg.xwd ]}
  '';

  meta = with lib; {
    homepage = "https://github.com/icholy/ttygif";
    description = "Convert terminal recordings to animated gifs";
    platforms = platforms.unix;
    license = licenses.mit;
    maintainers = with maintainers; [ moaxcp ];
  };
}
