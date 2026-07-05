{
  lib,
  stdenv,
  fetchurl,
}:
let
  version = "0.2.39";

  # Prebuilt, statically-linked Go binaries distributed via https://cdn.getmoshi.app.
  # Hashes are the upstream checksums.txt values for hook/v${version}.
  sources = {
    "x86_64-linux" = {
      asset = "moshi-hook_Linux_x86_64.tar.gz";
      hash = "sha256-CAd+x0Bb4+b9z832Sv2UGMtWDs43xXaD4DUjuVMotKQ=";
    };
    "aarch64-linux" = {
      asset = "moshi-hook_Linux_arm64.tar.gz";
      hash = "sha256-jE4559ZM6QJw209GAZYg+Th1JKM+mNvEPlTPJ6Kmi7c=";
    };
    "x86_64-darwin" = {
      asset = "moshi-hook_Darwin_x86_64.tar.gz";
      hash = "sha256-JXO1pPKlBfiYhCGrvVPT33sDEOOn/i1SemoYdPrMiPs=";
    };
    "aarch64-darwin" = {
      asset = "moshi-hook_Darwin_arm64.tar.gz";
      hash = "sha256-ChQ34uBF5yquZemsvpZMxz4ZXYsl89VvA37RXAvnmeg=";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "moshi-hook: unsupported platform ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "moshi-hook";
  inherit version;

  src = fetchurl {
    url = "https://cdn.getmoshi.app/hook/v${version}/${source.asset}";
    inherit (source) hash;
  };

  sourceRoot = ".";

  # Upstream ships a fully static binary; nothing to patch or link.
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 moshi-hook $out/bin/moshi-hook
    ln -s moshi-hook $out/bin/moshi

    install -Dm644 README.md -t $out/share/doc/moshi-hook
    install -Dm644 docs/*.md -t $out/share/doc/moshi-hook/docs

    runHook postInstall
  '';

  meta = {
    description = "moshi-hook - pair terminal/agent sessions across SSH and Mosh";
    homepage = "https://getmoshi.app";
    mainProgram = "moshi-hook";
    platforms = lib.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
