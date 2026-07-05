{ lib, config, ... }:
lib.mkIf config.ai.pi.enable { }
