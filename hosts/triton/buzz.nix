# Buzz desktop (https://github.com/block/buzz) — a Tauri/WebKitGTK app.
#
{ pkgs, ... }:
let
  version = "0.4.25";

  # Prebuilt binaries + desktop entry + icons, straight out of the .deb.
  buzz-unwrapped = pkgs.stdenvNoCC.mkDerivation {
    pname = "buzz-unwrapped";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://github.com/block/buzz/releases/download/v${version}/Buzz_${version}_amd64.deb";
      hash = "sha256-Wy6ybnXcG+IBVOBEomj3HAzu16VgoDKnP5du1D1s/oc=";
    };
    nativeBuildInputs = [ pkgs.dpkg ];
    unpackPhase = "dpkg-deb -x $src .";
    dontConfigure = true;
    dontBuild = true;
    # These are upstream prebuilt binaries run via the FHS env below — do not
    # strip or rewrite their interpreter/rpath.
    dontStrip = true;
    dontPatchELF = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r usr/. $out/
      runHook postInstall
    '';
  };

  # FHS env supplying the system libraries buzz-desktop needs (notably the
  # working nixpkgs WebKitGTK) plus GStreamer plugins for the voice pipeline.
  buzz = pkgs.buildFHSEnv {
    name = "buzz";
    runScript = "${buzz-unwrapped}/bin/buzz-desktop";
    profile = ''
      # nixpkgs installs GStreamer plugins here; point discovery at them so the
      # WebKit media pipeline (mic capture / TTS playback) can be built.
      export GST_PLUGIN_SYSTEM_PATH_1_0=/usr/lib/gstreamer-1.0
      # WebKitGTK's DMABUF renderer is flaky under nested/portal setups; disable
      # it for a reliable first paint. Safe to drop if hardware accel is wanted.
      export WEBKIT_DISABLE_DMABUF_RENDERER=1
    '';
    targetPkgs =
      pkgs:
      with pkgs;
      [
        # WebKit / Tauri core
        webkitgtk_4_1
        gtk3
        glib
        glib-networking
        libsoup_3
        # rendering / text stack
        cairo
        pango
        gdk-pixbuf
        harfbuzz
        librsvg
        atk
        at-spi2-atk
        at-spi2-core
        # settings / schemas
        gsettings-desktop-schemas
        dconf
        # crypto / net
        openssl
        zlib
        curl
        nss
        nspr
        # GStreamer + plugins (Buzz is a voice/transcription app)
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-libav
        gst_all_1.gst-plugins-ugly
        # graphics
        libGL
        libglvnd
        mesa
        libdrm
        # X / Wayland
        libx11
        libxext
        libxrender
        libxi
        libxcursor
        libxdamage
        libxfixes
        libxcomposite
        libxrandr
        libxtst
        libxcb
        wayland
        libxkbcommon
        # fonts
        fontconfig
        freetype
        # audio backends
        alsa-lib
        libpulseaudio
        pipewire
        # misc runtime
        dbus
        libnotify
        expat
        libffi
        pcre2
      ];
    # Install the desktop entry + icons and point Exec at the FHS wrapper so
    # Buzz shows up in the app launcher.
    extraInstallCommands = ''
      mkdir -p $out/share
      cp -r ${buzz-unwrapped}/share/applications $out/share/ 2>/dev/null || true
      cp -r ${buzz-unwrapped}/share/icons $out/share/ 2>/dev/null || true
      for d in $out/share/applications/*.desktop; do
        [ -e "$d" ] || continue
        substituteInPlace "$d" \
          --replace-quiet "Exec=buzz-desktop" "Exec=buzz" \
          --replace-quiet "Exec=/usr/bin/buzz-desktop" "Exec=buzz"
      done
    '';
  };
in
{
  environment.systemPackages = [ buzz ];
}
