{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeBinaryWrapper,
  versionCheckHook,
  nodejs_24,
  gcc,
  zlib,
  curl,
  expat,
  fontconfig,
}:
let
  version = "2.0.0-beta.17";

  throwSystem = throw "executor: unsupported platform ${stdenvNoCC.hostPlatform.system}";

  # npm publishes the base CLI (`executor@${version}`) plus one "native runtime"
  # tarball per platform (`executor@${version}-${npmPlatform}`). The base package
  # aliases the runtime as `executor-<platform>-<arch>` in optionalDependencies
  # and its `bin.mjs` resolves `${platformPkg}/bin.mjs` from its own node_modules.
  # Keep `npmPlatform` in sync with `platforms()` in update.sh.
  npmPlatform = {
    x86_64-linux = "linux-x64";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "darwin-x64";
    aarch64-darwin = "darwin-arm64";
  };

  platform = npmPlatform.${stdenvNoCC.hostPlatform.system} or throwSystem;
  platformPkg = "executor-${platform}";

  # The base tarball is platform-independent, so it gets one shared hash.
  baseHash = "sha256-mAqeRbqkhofyXECU6IB9xbePOiZUyFYUiRsdkuTfQss=";

  platformHashes = {
    x86_64-linux = "sha256-rzjb05xBj1hrtS8LEmT88Ps1Ne1VT5eXv8YBRPDWbJE=";
    aarch64-linux = "sha256-4iTi3M838dE/CUBJWkPblYqdCQNAaja0qsue8VbrkXc=";
    x86_64-darwin = "sha256-ZpXe63CNeaV9SFQnPPZxxkjDBhoH1iFVlnQHYxo0u0g=";
    aarch64-darwin = "sha256-EykY6P1TKw15VVFhI+N59l3r010k/PddEppmUU6AU1w=";
  };

  base = fetchurl {
    url = "https://registry.npmjs.org/executor/-/executor-${version}.tgz";
    hash = baseHash;
  };

  runtime = fetchurl {
    url = "https://registry.npmjs.org/executor/-/executor-${version}-${platform}.tgz";
    hash = platformHashes.${stdenvNoCC.hostPlatform.system} or throwSystem;
  };
in
stdenvNoCC.mkDerivation {
  pname = "executor";
  inherit version;

  # Two tarballs are unpacked manually in installPhase.
  src = null;

  nativeBuildInputs = [
    makeBinaryWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isElf [ autoPatchelfHook ];

  # The runtime ships prebuilt glibc binaries (workerd, dugite's git, sharp,
  # keyring) with no usable rpath. autoPatchelf links them against the store's
  # libc/libstdc++/libz/libcurl (git's http helpers), libexpat (git-http-push)
  # and fontconfig (the bundled SkiaSharp). The bundled libvips is found via
  # sharp's own `$ORIGIN` rpath plus the extra search path below.
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    gcc.cc.lib
    zlib
    curl
    expat
    fontconfig
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  # Native addons (.node, workerd, git) break when stripped.
  dontStrip = true;

  preFixup = lib.optionalString stdenvNoCC.hostPlatform.isElf ''
    # sharp's .node links libvips-cpp, which lives in its own sibling package
    # directory; make sure autoPatchelf can resolve it.
    addAutoPatchelfSearchPath "$out/lib/node_modules/executor/node_modules/${platformPkg}/node_modules/@img/sharp-libvips-${platform}/lib"
  '';

  installPhase = ''
    runHook preInstall

    # Reproduce a global npm install layout: the base package plus the aliased
    # runtime under `executor/node_modules/`, which is how `bin.mjs` resolves it.
    mkdir -p "$out/lib/node_modules/executor/node_modules" "$out/bin"
    tar xzf "${base}" --strip-components=1 -C "$out/lib/node_modules/executor"
    mkdir -p "$out/lib/node_modules/executor/node_modules/${platformPkg}"
    tar xzf "${runtime}" --strip-components=1 -C "$out/lib/node_modules/executor/node_modules/${platformPkg}"

    makeBinaryWrapper "${nodejs_24}/bin/node" "$out/bin/executor" \
      --add-flags "$out/lib/node_modules/executor/bin.mjs"

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
