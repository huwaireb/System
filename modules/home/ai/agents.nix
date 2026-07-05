{ lib, config, ... }:
lib.mkIf config.ai.agents.enable { }
