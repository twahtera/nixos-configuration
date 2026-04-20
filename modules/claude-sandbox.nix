{ pkgs, lib, inputs, ... }:

let
  cfg = {
    hostIp          = "10.200.0.1";
    vmIp            = "10.200.0.2";
    subnet          = "10.200.0.0/24";
    bridgeName      = "br-claude";
    tapId           = "microvm-claude";
    vmMac           = "02:00:00:00:00:01";
    externalIface   = "enp37s0";
    projectLink     = "/home/ent/microvm-project";
    claudeCredsPath = "/home/ent/claude-microvm";
    sshKey          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8M9+Jl6oMwviZBHjPvcKeYDoDZgIpxrq6zyeqI5l3Fbrntp+I0OJ2XSFjSL9aM0fdcB9+XeM1Y0Bdb3Io1hkj5POoVcgjHt8tCWpkaCsBpVBHM/3G0yEBtMp44T56QePL+n1zIVRCUkw6OwLu5wPFfbdKbcy+pWTynqEvzNqJNfcIcuoSmZE8Og1wcOuP9LGjEBqQVZIttPQy4lEBIpubH1QHl6B5Ibabxew3TaUkBs9vWedeUlTSw0RI6IywuiViDwhMzAY7IKJg5Isa49ZfETkxMvDdQbDXQg0tgOKS9MturgUOZ/ap5nfOAyT44aWeETFdlwVL4IIFfbdBFVjP entgod@kakeme";
  };
  system = "x86_64-linux";
in {
  # ── Host networking ────────────────────────────────────────────────
  networking.useNetworkd  = true;
  networking.useDHCP      = false;
  services.resolved.enable = true;

  networking.networkmanager.unmanaged = [
    "interface-name:${cfg.bridgeName}"
    "interface-name:microvm*"
  ];

  systemd.network.networks."10-physical" = {
    matchConfig.Name = cfg.externalIface;
    networkConfig = { DHCP = "yes"; IPv6AcceptRA = true; };
  };

  systemd.network.netdevs."20-br-claude".netdevConfig = {
    Kind = "bridge";
    Name = cfg.bridgeName;
  };

  systemd.network.networks."20-br-claude" = {
    matchConfig.Name = cfg.bridgeName;
    addresses = [{ Address = "${cfg.hostIp}/24"; }];
    networkConfig.ConfigureWithoutCarrier = true;
  };

  systemd.network.networks."21-microvm-tap" = {
    matchConfig.Name = "microvm*";
    networkConfig.Bridge = cfg.bridgeName;
  };

  networking.nat = {
    enable             = true;
    internalInterfaces = [ cfg.bridgeName ];
    externalInterface  = cfg.externalIface;
  };

  networking.nftables.enable = true;
  networking.firewall.extraForwardRules = ''
    ip saddr ${cfg.subnet} ip daddr 192.168.0.0/16 drop
    ip saddr ${cfg.subnet} ip daddr 172.16.0.0/12  drop
    ip saddr ${cfg.subnet} ip daddr 10.0.0.0/8 ip daddr != ${cfg.subnet} drop
  '';

  # ── Host permissions ───────────────────────────────────────────────
  users.groups.kvm.members = [ "ent" ];
  boot.kernelModules = [ "tun" ];

  systemd.tmpfiles.rules = [
    "d ${cfg.claudeCredsPath} 0700 ent users -"
    "d ${cfg.projectLink}     0755 ent users -"
  ];

  # ── VM ─────────────────────────────────────────────────────────────
  microvm.vms.claude-sandbox = {
    autostart = false;
    config = {
      imports = [ inputs.microvm.nixosModules.microvm ];

      system.stateVersion  = "24.11";
      nixpkgs.hostPlatform = system;

      systemd.settings.Manager.DefaultTimeoutStopSec = "5s";

      systemd.mounts = [{
        what  = "store";
        where = "/nix/store";
        overrideStrategy = "asDropin";
        unitConfig.DefaultDependencies = false;
      }];

      microvm = {
        hypervisor          = "cloud-hypervisor";
        mem                 = 8192;
        vcpu                = 4;
        vsock.cid           = 42;
        socket              = "control.socket";
        writableStoreOverlay = "/var/nix-store-overlay";

        volumes = [{
          mountPoint = "/var";
          image      = "var.img";
          size       = 51200;
        }];

        interfaces = [{
          type = "tap";
          id   = cfg.tapId;
          mac  = cfg.vmMac;
        }];

        shares = [
          {
            proto      = "virtiofs";
            tag        = "ro-store";
            source     = "/nix/store";
            mountPoint = "/nix/.ro-store";
          }
          {
            proto      = "virtiofs";
            tag        = "workspace";
            source     = cfg.projectLink;
            mountPoint = "/project";
          }
          {
            proto      = "virtiofs";
            tag        = "claude-creds";
            source     = cfg.claudeCredsPath;
            mountPoint = cfg.claudeCredsPath;
          }
        ];
      };

      networking = {
        hostName                     = "claude-sandbox";
        usePredictableInterfaceNames = false;
        useDHCP                      = false;
        firewall.enable              = false;
        nameservers                  = [ "1.1.1.1" "1.0.0.1" ];
        interfaces.eth0.ipv4.addresses = [{
          address      = cfg.vmIp;
          prefixLength = 24;
        }];
        defaultGateway = { address = cfg.hostIp; interface = "eth0"; };
      };

      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
        settings.PermitRootLogin        = "no";
        hostKeys = [{
          path = "${cfg.claudeCredsPath}/ssh_host_ed25519_key";
          type = "ed25519";
        }];
      };

      services.getty.autologinUser = "root";
      users.users.root.password    = "";

      users.groups.ent = { gid = 1000; };
      users.users.ent  = {
        isNormalUser = true;
        uid          = 1000;
        group        = "ent";
        shell        = pkgs.bash;
        openssh.authorizedKeys.keys = [ cfg.sshKey ];
      };

      environment.sessionVariables = {
        CLAUDE_CONFIG_DIR = cfg.claudeCredsPath;
        XDG_CACHE_HOME    = "/var/cache/ent";
      };

      programs.ssh.extraConfig = ''
        IdentityFile ${cfg.claudeCredsPath}/id_ed25519
      '';

      environment.etc."profile.d/00-project.sh".text = ''
        [ -d /project ] && cd /project
      '';

      nix.settings = {
        trusted-users         = [ "root" "ent" ];
        experimental-features = [ "nix-command" "flakes" ];
        # Build in /var so nix sandboxes don't fill the 2GB rootfs tmpfs.
        build-dir             = "/var/nix-build";
      };

      systemd.tmpfiles.rules = [
        "d /var/cache/ent  0755 ent users -"
        "d /var/nix-build  0755 root root -"
      ];

      environment.systemPackages = with pkgs; [
        claude-code
        devenv
        kitty.terminfo
        git
        curl
        jq
        bash
        coreutils
        iproute2
        process-compose
      ];
    };
  };
}
