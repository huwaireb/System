{
  lib,
  stdenv,
  apple-sdk,
  darwinMinVersionHook,
  CLANG_FLAGS ? [
    "-O3"
    "-flto"
    "-march=native"
    "-Wall"
    "-Wextra"
    "-Werror"
  ],
  OBJC_FLAGS ? [
    "-fobjc-arc"
    "-fmodules"
  ],
}:
stdenv.mkDerivation {
  pname = "set-wallpaper";
  version = "0.1.0";

  src = ./src;
  dontUnpack = true;

  inherit CLANG_FLAGS OBJC_FLAGS;

  buildInputs = lib.optionals stdenv.isDarwin [
    apple-sdk
    (darwinMinVersionHook "10.6") # When setDesktopImageURL was introduced
  ];

  buildPhase =
    ''
      clang -c $src/main.c -o main.o $CLANG_FLAGS
    ''
    + lib.optionalString stdenv.isDarwin ''
      clang $OBJC_FLAGS $CLANG_FLAGS \
                  -framework Foundation -framework AppKit \
                  $src/os/darwin.m main.o -o SetWallpaper
    '';

  installPhase = ''
    install -Dm 755 SetWallpaper $out/bin/SetWallpaper
  '';

  meta.platforms = lib.platforms.darwin;
  meta.mainProgram = "SetWallpaper";
}
