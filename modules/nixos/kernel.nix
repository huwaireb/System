{ pkgs, ... }:
{
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  boot.kernel.sysctl = {
    "kernel.sysrq" = 0;
    "kernel.kptr_restrict" = 2;
    "net.core.bpf_jit_enable" = false;
    "kernel.ftrace_enabled" = false;
    "kernel.dmesg_restrict" = 1;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "fs.suid_dumpable" = 0;
    "kernel.perf_event_paranoid" = 3;
    "kernel.unprivileged_bpf_disabled" = 1;
  };

  boot.kernelParams = [
    "randomize_kstack_offset=on"
    "vsyscall=none"
    "slab_nomerge"
    "module.sig_enforce=1"
    "lockdown=integrity"
    "page_poison=1"
    "page_alloc.shuffle=1"
    "sysrq_always_enabled=0"
    "rootflags=noatime"
    "lsm=landlock,apparmor,integrity"
    "fbcon=nodefer"
  ];

  boot.blacklistedKernelModules = [
    # Legacy protocols and filesystems only
    "af_802154"
    "appletalk"
    "atm"
    "ax25"
    "can"
    "dccp"
    "decnet"
    "econet"
    "ipx"
    "n-hdlc"
    "netrom"
    "p8022"
    "p8023"
    "psnap"
    "rds"
    "rose"
    "tipc"
    "x25"
    "adfs"
    "affs"
    "befs"
    "bfs"
    "cramfs"
    "efs"
    "exofs"
    "freevxfs"
    "gfs2"
    "hpfs"
    "jffs2"
    "minix"
    "nilfs2"
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "udf"
    "vivid"
    "firewire-core"
    "nouveu"
  ];
}
