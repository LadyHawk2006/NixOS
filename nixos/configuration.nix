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
    steam-hardware.enable = true; # Enables udev rules for controllers (Steam Controller, Xbox, PS5)
    graphics = {
      enable = true;
      enable32Bit = true; # Required for 32-bit games and Proton DirectX/Vulkan translation
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
  # 3. Bootloader & Kernel (CachyOS)
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

    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;
    kernelModules = [ "xpad" "uinput" ];
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };

  # ============================================================================
  # 4. Networking, Firewall & Tailscale
  # ============================================================================
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ "waydroid0" "tailscale0" ];
      allowedTCPPorts = [ 8080 53317 ];
      allowedUDPPorts = [ 8080 41641 53317 ];
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; }
        { from = 30000; to = 50000; }
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; }
      ];
    };
  };

  services.tailscale.enable = true;

  # ============================================================================
  # 5. Localization & User Configuration
  # ============================================================================
  time.timeZone = "Africa/Nairobi";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users."shadrack" = {
    isNormalUser = true;
    description = "Shadrack";
    extraGroups = [ "networkmanager" "wheel" "input" "adbusers" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  # ============================================================================
  # 6. Core Services, Virtualization & Network Storage
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

  # -- Waydroid Virtualization --
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };
  systemd = {
    packages = [ pkgs.waydroid-helper ];
    services.waydroid-mount.wantedBy = [ "multi-user.target" ];
  };

  # -- Local Network File Sharing (Samba) --
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
    } // pkgs.lib.genAttrs [ "Videos" "Music" ] (folder: {
      "path" = "/home/shadrack/${folder}";
      "browseable" = "yes";
      "read only" = "yes";
      "guest ok" = "no";
    });
  };

  # ============================================================================
  # 7. Desktop Environment (Hyprland), Gaming & Display
  # ============================================================================
  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    uwsm.enable = true;
    dms-shell = {
      enable = true;
      package = pkgs.dms-shell;
    };
    gpu-screen-recorder.enable = true;
    gamemode.enable = true; # Improves performance while playing games

    # Steam Module Configuration
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin # Adds Proton-GE for improved game compatibility
      ];
    };
  };

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "hyprland";
    configHome = "/home/shadrack";
  };

  services.xserver.xkb = { layout = "us"; variant = ""; };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb";
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "iHD";
  };

  qt = { enable = true; platformTheme = "qt5ct"; };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    font-awesome
    noto-fonts-color-emoji
  ];

  # ============================================================================
  # 8. System Packages
  # ============================================================================
  environment.systemPackages = with pkgs; [

    # -- Utilities & CLI Tools --
    android-tools bat brightnessctl curl eza fastfetch ffmpeg-full
    ffmpegthumbnailer git libnotify nodejs playerctl python3 scrcpy
    usbutils uv vim wev wget wl-clipboard yt-dlp
    wineWow64Packages.wayland nix-output-monitor steam-run grimblast

    # -- GUI Applications & System Tools --
    bazaar gapless gdu ghostty glava google-chrome
    gpu-screen-recorder-gtk kdePackages.dolphin kdePackages.gwenview
    kdePackages.kwallet kdePackages.partitionmanager localsend
    nautilus proton-vpn spotify valent waydroid-helper zed-editor

    # -- Development & Core Libraries --
    nil nixd ocamlPackages.gstreamer gitleaks

    # -- Desktop Environment & Theming Engines --
    adwaita-icon-theme breeze-hacked-cursor-theme candy-icons hyprpolkitagent
    libsForQt5.qt5ct qt6Packages.qt6ct qt6.qtbase qt6.qtwayland qtengine
    sweet-folders

    # -- Customized Media Player --
    (mpv.override {
      scripts = with mpvScripts; [
        mpris sponsorblock quality-menu mpv-playlistmanager thumbfast
      ];
    })
  ];
}
