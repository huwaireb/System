{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      _module.args = rec {
        lib = self.lib // pkgs.lib;
        l = builtins // lib;
      };
    };
}
