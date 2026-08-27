{
  lib,
  stdenv,
  fetchurl,
}:
let
  version = "0.3.1";

  # Prebuilt, statically-linked Go binaries distributed via https://cdn.getmoshi.app.
  # Hashes are the upstream checksums.txt values for hook/v${version}.
  sources = {
    "x86_64-linux" = {
      asset = "moshi-hook_Linux_x86_64.tar.gz";
      hash = "sha256-fvvRgvVKjUTZpUxGuyqbFj1wnNoXJlKnw1dIcW8qag8=";
    };
    "aarch64-linux" = {
      asset = "moshi-hook_Linux_arm64.tar.gz";
      hash = "sha256-1OQK80n4ueeIqJWod/QPZTQGYIAparnKhORxaB5hu3Q=";
    };
    "x86_64-darwin" = {
      asset = "moshi-hook_Darwin_x86_64.tar.gz";
      hash = "sha256-XhISXnETz4hcwGXo1Q/X3aojD7EyLOA21PhwVkD9F68=";
    };
    "aarch64-darwin" = {
      asset = "moshi-hook_Darwin_arm64.tar.gz";
      hash = "sha256-i0xtgMuz2r1QL1gEXgkYoiMVIXYUcR6rxGmtc+RzTXg=";
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
