{ stdenv, lib, fetchFromGitHub, rustPlatform, libiconv, llvmPackages, v8 }:

rustPlatform.buildRustPackage rec {
  pname = "rq";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "dflemstr";
    repo = pname;
    rev = "v${version}";
    sha256 = "0km9d751jr6c5qy4af6ks7nv3xfn13iqi03wq59a1c73rnf0zinp";
  };

  postPatch = ''
    # Remove #[deny(warnings)] which is equivalent to -Werror in C.
    # Prevents build failures when upgrading rustc, which may give more warnings.
    substituteInPlace src/lib.rs \
      --replace "#![deny(warnings)]" ""
  '';

  cargoSha256 = "0c5vwy3c5ji602dj64z6jqvcpi2xff03zvjbnwihb3ydqwnb3v67";

  buildInputs = [ llvmPackages.clang-unwrapped v8 ]
  ++ lib.optionals stdenv.isDarwin [ libiconv ];

  configurePhase = ''
    export LIBCLANG_PATH="${llvmPackages.clang-unwrapped}/lib"
    export V8_SOURCE="${v8}"
  '';

  meta = with lib; {
    description = "A tool for doing record analysis and transformation";
    homepage = "https://github.com/dflemstr/rq";
    license = with licenses; [ asl20 ];
    maintainers = with maintainers; [ aristid Br1ght0ne ];
  };
}
