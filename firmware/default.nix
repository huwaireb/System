{
  perSystem =
    { pkgs, ... }:
    {
      devShells.firmware = pkgs.mkShell {
        packages = builtins.attrValues {
          inherit (pkgs) dtc cmake ninja;
        };
      };
    };
}
