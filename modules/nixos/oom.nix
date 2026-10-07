# Proactive OOM avoidance.
#
# The kernel OOM killer is *reactive*: it fires at the last instant, after swap
# is exhausted and the machine has already swap-thrashed into unresponsiveness.
# On a desktop with a 64 GiB swapfile that's a real risk — lots of swap capacity
# just means a longer, more painful death spiral before the killer finally acts.
#
# Layers (cheap → thorough):
#   1. systemd-oomd — cgroup/PSI + global swap cap for system services
#   2. earlyoom     — process-level killer (the single worst offender)
#   3. zram         — compressed in-RAM swap so swapping is fast, not a spiral
#   4. vm.* sysctls — gentler reclaim, fewer latency spikes
{
  config,
  lib,
  ...
}:
{
  # --- 1. systemd-oomd (cgroup/PSI + global swap cap) ------------------------
  #
  # `enableUserSlices` is deliberately left OFF: it would set
  # `ManagedOOMMemoryPressure=kill` on `user@.slice`, so a pressure spike in the
  # desktop session would make oomd kill the *entire* login session (log you
  # out, taking every app with it). For a single-user desktop that's worse than
  # losing one app — user-app protection lives in earlyoom below instead.
  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableSystemSlice = true;
    settings.OOM = {
      SwapUsedLimit = "90%";              # act once swap is 90% full
      DefaultMemoryPressureLimit = "60%"; # PSI pressure trigger for managed slices
      DefaultMemoryPressureDurationSec = "20s";
    };
  };

  # --- 2. earlyoom (process-level safety net for user apps) ------------------
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;   # kick in at 5% free RAM, before thrash begins
    freeSwapThreshold = 5;  # ...or 5% free swap
    extraArgs = [
      # Never kill the game/stream session (SIGTERM'ing mid-stream is ugly).
      "--avoid '(^|/)steam$|(^|/)sunshine$'"
      # Prefer the agent CLIs + executor: biggest memory hogs, least unsaved work.
      "--prefer '(^|/)(codex|claude|opencode|grok|pi|executor)$'"
    ];
  };

  # --- 3. zram compressed swap -----------------------------------------------
  zramSwap = {
    enable = true;
    memoryPercent = 50;   # zram device sized to 50% of RAM
    algorithm = "zstd";
    priority = 100;       # prefer fast zram over the disk swapfile/partition
  };

  # --- 4. gentler reclaim ------------------------------------------------------
  boot.kernel.sysctl = {
    "vm.swappiness" = 30;              # bias toward RAM before swapping out
    "vm.watermark_scale_factor" = 100; # reclaim earlier/smoother, fewer stalls
  };
}
