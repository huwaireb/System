{ lib, config, ... }:
lib.mkIf config.ai.moshi.enable { }
