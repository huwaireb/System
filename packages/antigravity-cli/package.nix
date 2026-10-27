# Prebuilt upstream binary, resolved from the same per-platform manifests as
# https://antigravity.google/cli/install.sh. Update with `./update.sh`.
{
  lib,
  stdenvNoCC,
  fetchurl,
  makeBinaryWrapper,
  autoPatchelfHook,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  manifest ? lib.importJSON ./manifest.json,
}:
let
  # Keep in sync with `PLATFORMS` in update.sh.
  platformKey =
    {
      x86_64-linux = "linux_amd64";
      aarch64-linux = "linux_arm64";
      x86_64-darwin = "darwin_amd64";
      aarch64-darwin = "darwin_arm64";
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "antigravity-cli: unsupported platform ${stdenvNoCC.hostPlatform.system}");

  platformManifestEntry = manifest.platforms.${platformKey};
in
stdenvNoCC.mkDerivation {
  pname = "antigravity-cli";
  inherit (manifest) version;

  src = fetchurl {
    inherit (platformManifestEntry) url sha512;
  };

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;
  # Go binary; stripping gains nothing and risks breaking embedded data.
  dontStrip = true;

  strictDeps = true;

  nativeBuildInputs = [
    makeBinaryWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    install -Dm755 antigravity "$out/libexec/antigravity-cli/agy"

    # The CLI self-updates in place by default, which can't work from the store.
    makeBinaryWrapper "$out/libexec/antigravity-cli/agy" "$out/bin/agy" \
      --set AGY_CLI_DISABLE_AUTO_UPDATE 1

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "--version";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Google Antigravity terminal agent client";
    homepage = "https://antigravity.google";
    mainProgram = "agy";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
