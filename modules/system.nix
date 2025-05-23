{ lib, ... }:
let
  inherit (lib) types;
in
{
  options.type = lib.mkOption {
    type = types.enum [
      "desktop"
      "server"
    ];
    default = "server";
    description = "The type of host system";
  };
}
