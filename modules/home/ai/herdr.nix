{ lib, config, ... }:
lib.mkIf config.ai.herdr.enable { }
