{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeBinaryWrapper,
  installShellFiles,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  ripgrep,
  sysctl,
  darwin,
}:
let
  version = "2.0.22";

  throwSystem = throw "opencode: unsupported platform ${stdenvNoCC.hostPlatform.system}";

  # npm publishes one tarball per `@opencode/cli-${npmPlatform}`.
  # Keep `npmPlatform` in sync with `platforms()` in update.sh.
  npmPlatform = {
    x86_64-linux = "linux-x64";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "darwin-x64";
    aarch64-darwin = "darwin-arm64";
  };

  hashes = {
    x86_64-linux = "sha512-DlV1qgEDDnVqpTWMPqv7tCHCcXodzZBFaMcxjsiYdY6E5gHH2Q68JfasVksyQ1nu6m1887WQKGhOsepE+oKyYw==";
    aarch64-linux = "sha512-t/yuu9Dqd/M44dFH95bphu7ikO6FATMQuVk/91QBnCMzsP8zVrXU7zAxD1wVLpYYUDqIonEmi80XETlFqx7chw==";
    x86_64-darwin = "sha512-R/o6HCCHdcDlmXSqveuYBBTB3mrGjMvG4H2AO3PpUJ2X1VEaHhei0BQ0nckGjJh6JXe7J/zJZqpxuBsVJbHfOw==";
    aarch64-darwin = "sha512-NNg1VCCTWSfLlNKpRb4RA6IE7H67ZBLBYmfIWjP3CxR9NPtdROQFCL8lpPf+Tz2Qje4Bb27sQOLWanYyNT/9dQ==";
  };

  platform = npmPlatform.${stdenvNoCC.hostPlatform.system} or throwSystem;
in
stdenvNoCC.mkDerivation {
  pname = "opencode";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@opencode/cli-${platform}/-/cli-${platform}-${version}.tgz";
    hash = hashes.${stdenvNoCC.hostPlatform.system} or throwSystem;
  };

  sourceRoot = "package";

  dontConfigure = true;
  dontBuild = true;
  # Bun-compiled binaries break when stripped.
  dontStrip = true;

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [ darwin.sigtool ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/libexec/opencode" "$out/bin"
    install -m755 bin/opencode "$out/libexec/opencode/opencode"

    makeBinaryWrapper "$out/libexec/opencode/opencode" "$out/bin/opencode" \
      --set OPENCODE_DISABLE_AUTOUPDATE true \
      --prefix PATH : ${
        lib.makeBinPath (
          [ ripgrep ]
          ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [ sysctl ]
        )
      }
    ln -s opencode "$out/bin/opencode2"

    runHook postInstall
  '';

  postInstall = lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
    codesign --force --sign - "$out/libexec/opencode/opencode"
  '';

  # autoPatchelf runs in postFixup, so the binary is only runnable after that.
  postPhases = [ "postPatchelf" ];
  postPatchelf = lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
    # Generate one shell at a time. Process substitutions start together and
    # the fish script is larger than a pipe buffer, so Bun stops at 64KiB.
    mkdir completions
    "$out/bin/opencode" --completions bash > completions/opencode.bash
    "$out/bin/opencode" --completions fish > completions/opencode.fish
    "$out/bin/opencode" --completions zsh > completions/_opencode
    installShellCompletion --cmd opencode \
      --bash completions/opencode.bash \
      --fish completions/opencode.fish \
      --zsh completions/_opencode
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "--version";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Open source coding agent";
    homepage = "https://opencode.ai";
    changelog = "https://github.com/anomalyco/opencode/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "opencode";
    platforms = lib.attrNames npmPlatform;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
