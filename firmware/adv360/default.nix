# FIXME: Fails due to Kconfig errors out of my reach.
{
  # Inputs
  zephyr,
  zmk,

  # Scope
  lib,
  stdenv,
  cmake,
  ninja,
  python3,
  dtc,
  gcc-arm-embedded,
  darwin,
}:
stdenv.mkDerivation {
  pname = "Advantage 360 Pro Firmware";
  version = "0.1.0";

  src = "${zmk}/app";

  nativeBuildInputs =
    [
      cmake
      ninja
      dtc
      (python3.withPackages (
        ps: with ps; [
          pyyaml
          pykwalify
        ]
      ))
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.DarwinTools
    ];

  env = {
    ZEPHYR_TOOLCHAIN_VARIANT = "gnuarmemb";
    GNUARMEMB_TOOLCHAIN_PATH = gcc-arm-embedded;

    CMAKE_PREFIX_PATH = "$CMAKE_PREFIX_PATH:${zephyr}";
    CMAKE_IGNORE_PATH = lib.concatStringsSep "," (
      map (module: "${zephyr}/modules/${module}") [
        "ci-tools"
        "hal_altera"
        "hal_cypress"
        "hal_infineon"
        "hal_microchip"
        "hal_nxp"
        "hal_openisa"
        "hal_silabs"
        "hal_xtensa"
        "hal_st"
        "hal_ti"
        "loramac-node"
        "mcuboot"
        "mcumgr"
        "net-tools"
        "openthread"
        "edtt"
        "trusted-firmware-m"
      ]
    );
  };

  cmakeFlags = [
    "-DCMAKE_C_COMPILER=${gcc-arm-embedded}/bin/arm-none-eabi-gcc" # Is this even correct?
    "-DBOARD_ROOT=${zmk}/app"
    "-DBOARD=adv360pro_left"
    "-DZMK_CONFIG=${./config}"
    "-DZEPHYR_BASE=${zephyr}"
    "-DCONFIG_COMPILER_WARNINGS_AS_ERRORS=n"
  ];
}
