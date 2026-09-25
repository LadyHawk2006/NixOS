{ config, pkgs, inputs, ... }:

{
  # ============================================================================
  # 1. Imports & Core Nix Settings
  # ============================================================================
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "26.05";
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    substituters = [ "https://attic.xuyh0120.win/lantian" ];
    trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  };

  # ============================================================================
  # 2. Hardware, Peripherals & Graphics
  # ============================================================================
  hardware = {
    bluetooth.enable = true;
    xone.enable = true;
    steam-hardware.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
      ];
    };
  };

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
    KERNEL=="event*", NAME="input/%k", MODE="0666"
  '';

  services.acpid.enable = true;
  services.upower.enable = true;
  services.printing.enable = true;
  services.blueman.enable = true;

  # ============================================================================
  # 3. Performance Optimization (No Throttling)
  # ============================================================================
  zramSwap.enable = true;
  services.fstrim.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  # ============================================================================
  # 4. Bootloader & Kernel (CachyOS)
  # ============================================================================
  boot = {
    loader = {
      systemd-boot.enable = false;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        theme = pkgs.nixos-grub2-theme;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };

    # Switched to the base 'latest' package to match the CI cache exactly
#    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
   kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;
    kernelModules = [ "xpad" "uinput" ];
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };

  services.scx.enable = true;

  # ============================================================================
  # 5. Networking, Firewall & Tailscale
  # ============================================================================
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ "waydroid0" "tailscale0" ];
      allowedTCPPorts = [ 8080 53317 ];
      allowedUDPPorts = [ 8080 41641 53317 ];
    };
  };

  services.tailscale.enable = true;

  # ============================================================================
  # 6. Localization & User Configuration
  # ============================================================================
  time.timeZone = "Africa/Nairobi";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users."shadrack" = {
    isNormalUser = true;
    description = "Shadrack";
    extraGroups = [ "networkmanager" "wheel" "input" "adbusers" ];
    shell = pkgs.fish;
  };

  # ============================================================================
  # 7. Core Services, Virtualization & Network Storage
  # ============================================================================
  security.polkit.enable = true;
  services.openssh.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.flatpak.enable = true;

  programs.fuse.userAllowOther = true;
  programs.nix-ld.enable = true;
  programs.dconf.enable = true;
  programs.fish.enable = true;

  programs.kdeconnect = {
    enable = true;
    package = pkgs.valent;
  };

  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };
  systemd = {
    packages = [ pkgs.waydroid-helper ];
    services.waydroid-mount.wantedBy = [ "multi-user.target" ];
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "NixOS Media";
        "netbios name" = "nixos";
        "security" = "user";
      };
    } // pkgs.lib.genAttrs [ "Videos" "Music" "Pictures" ] (folder: {
      "path" = "/home/shadrack/${folder}";
      "browseable" = "yes";
      "read only" = "yes";
      "guest ok" = "no";
    });
  };

  # ============================================================================
  # 8. Desktop Environment (Hyprland), Gaming & Display
  # ============================================================================
  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    uwsm.enable = true;
    gpu-screen-recorder.enable = true;
    gamemode.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "hyprland";
    configHome = "/home/shadrack";
  };

  services.xserver.xkb = { layout = "us"; variant = ""; };
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    font-awesome
    noto-fonts-color-emoji
  ];

  # ============================================================================
  # 9. Core System Packages
  # ============================================================================
  environment.systemPackages = with pkgs; [
    android-tools brightnessctl curl ffmpeg-full ffmpegthumbnailer git
    libnotify nodejs python3 usbutils uv wev wget wl-clipboard
    wineWow64Packages.wayland nix-output-monitor steam-run waydroid-helper

    qt6.qtbase qt6.qtwayland qtengine kdePackages.qt5compat
    kdePackages.qtdeclarative libsForQt5.qt5ct qt6Packages.qt6ct
  ];
}
