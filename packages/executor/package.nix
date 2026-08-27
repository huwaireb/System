{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeBinaryWrapper,
  versionCheckHook,
  gcc,
}:
let
  version = "1.6.0";

  throwSystem = throw "executor: unsupported platform ${stdenvNoCC.hostPlatform.system}";

  # npm publishes one platform tarball per `executor@${version}-${npmPlatform}`.
  # Keep `npmPlatform` in sync with `platforms()` in update.sh.
  npmPlatform = {
    x86_64-linux = "linux-x64";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "darwin-x64";
    aarch64-darwin = "darwin-arm64";
  };

  hashes = {
    x86_64-linux = "sha256-GNZfyH3OHEQy+pyfWBb6DUiDpLI6RA6Rl47ZVlXSy1A=";
    aarch64-linux = "sha256-IB9AgJ7BVCt9T6L6RC0JmelPgT4WzJxVBYjADnS2dDE=";
    x86_64-darwin = "sha256-hpTmyTinoi7//DreBBtXXlYuih1Kydo7YUwqhBCnNL8=";
    aarch64-darwin = "sha256-Ti6ELUK4RAt5Y5CrQN1rFKYF/+Y5mgWJliiurTFuoc8=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "executor";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/executor/-/executor-${version}-${
      npmPlatform.${stdenvNoCC.hostPlatform.system} or throwSystem
    }.tgz";
    hash = hashes.${stdenvNoCC.hostPlatform.system} or throwSystem;
  };

  # Native bindings and wasm sidecars are resolved from dirname(process.execPath).
  # Keep the bun binary and its siblings together; wrap a PATH entry on top.
  sourceRoot = "package";

  dontConfigure = true;
  dontBuild = true;
  # Bun-compiled binaries break when stripped.
  dontStrip = true;

  nativeBuildInputs = [
    makeBinaryWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ gcc.cc.lib ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/libexec/executor" "$out/bin"
    cp -a bin/. "$out/libexec/executor/"
    chmod +x "$out/libexec/executor/executor"
    if [ -f "$out/libexec/executor/workerd" ]; then
      chmod +x "$out/libexec/executor/workerd"
    fi

    makeBinaryWrapper "$out/libexec/executor/executor" "$out/bin/executor"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Local AI executor with a CLI, local API server, and web UI";
    homepage = "https://executor.sh";
    changelog = "https://github.com/UsefulSoftwareCo/executor/releases";
    license = lib.licenses.mit;
    mainProgram = "executor";
    platforms = lib.attrNames npmPlatform;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
