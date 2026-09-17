# ============================================================================
  #                     NIXOS CONFIGURATION FILE
  # ============================================================================

{ config, pkgs, ... }:

{
  # ============================================================================
  # Imports
  # ============================================================================

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # ============================================================================
  # Nixpkgs Configuration
  # ============================================================================

  nixpkgs.config.allowUnfree = true;


  # ============================================================================
  # System & Boot
  # ============================================================================

  boot.loader = {
      systemd-boot.enable = false;
        grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        # useOSProber = true; # (Optional) Uncomment if dual-booting with Windows/other OS

        theme = pkgs.nixos-grub2-theme;
      };

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  boot.kernelPackages = pkgs.linuxPackages_latest;
# boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
  boot.kernelModules = [ "xpad" "uinput" ];
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  system.stateVersion = "26.05";

  # ============================================================================
  # Networking & Localization
  # ============================================================================

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.firewall.trustedInterfaces = [ "waydroid0" "tailscale0" ];

  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      53317
      8080
    ];

    allowedUDPPorts = [
      53317
      8080
      41641
    ];

    allowedTCPPortRanges = [
      { from = 30000; to = 50000; }
      { from = 1714; to = 1764; }
    ];

    allowedUDPPortRanges = [
      { from = 1714; to = 1764; }
    ];
  };

  time.timeZone = "Africa/Nairobi";
  i18n.defaultLocale = "en_US.UTF-8";

  # ============================================================================
  # User Management & Shell
  # ============================================================================

  users.users."shadrack" = {
    isNormalUser = true;
    description = "Shadrack";
    extraGroups = [ "networkmanager" "wheel" "input" "adbusers" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  # ============================================================================
  # Hardware & Peripheral Configuration
  # ============================================================================

  hardware.bluetooth.enable = true;
  hardware.xone.enable = true; # Adds enhanced Xbox controller drivers/rules
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver  # For Broadwell (2014) and newer CPUs (uses iHD driver)
      intel-vaapi-driver  # Fallback for older i965 drivers
      libvdpau-va-gl
    ];
  };


  security.polkit.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
    KERNEL=="event*", NAME="input/%k", MODE="0666"
  '';

  services.openssh.enable = true;
  services.tailscale.enable = true;

  services.samba = {
    enable = true;
    openFirewall = true; # Automatically opens required SMB ports
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "NixOS Media";
        "netbios name" = "nixos";
        "security" = "user";
      };
      "Videos" = {
        "path" = "/home/shadrack/Videos";
        "browseable" = "yes";
        "read only" = "yes";
        "guest ok" = "no";
      };

      "Music" = {
        "path" = "/home/shadrack/Music";
        "browseable" = "yes";
        "read only" = "yes";
        "guest ok" = "no";
      };
    };
  };

  # ============================================================================
  # Desktop Environment & Display Services
  # ============================================================================
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.uwsm.enable = true;
  programs.fuse.userAllowOther = true;
  programs.dms-shell.enable = true;
  programs.dms-shell.package = pkgs.dms-shell;
  programs.nix-ld.enable = true;
  programs.dconf.enable = true;
  programs.gpu-screen-recorder.enable = true;

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "hyprland";
    configHome = "/home/shadrack";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb";
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "iHD";
  };


  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };


  # ============================================================================
  # System Services & Daemons
  # ============================================================================
  services.acpid.enable = true;
  services.blueman.enable = true;
  services.upower.enable = true;
  services.printing.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.flatpak.enable = true;

  # ============================================================================
  # Virtualization
  # ============================================================================
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;
  systemd = {
    packages = [ pkgs.waydroid-helper ];
    services.waydroid-mount.wantedBy = [ "multi-user.target" ];
  };

  # ============================================================================
  # Fonts
  # ============================================================================
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    font-awesome
    noto-fonts-color-emoji
  ];


  nix.settings.auto-optimise-store = true;



  # ============================================================================
  # System Packages
  # ============================================================================
  environment.systemPackages = with pkgs; [

    #---------------------------------------------------------------------------
    # Utilities & CLI Tools
    #---------------------------------------------------------------------------

    vim
    wget
    curl
    git
    wl-clipboard
    libnotify
    eza
    wev
    usbutils
    fastfetch
    yt-dlp
    android-tools
    scrcpy
    uv
    ffmpeg-full
    python3
    brightnessctl
    steam-run
    ffmpegthumbnailer
    playerctl
    nodejs
    bat
    wineWow64Packages.wayland

    #---------------------------------------------------------------------------
    # Terminal & GUI Applications
    #---------------------------------------------------------------------------

    ghostty
    nautilus
    gapless
    google-chrome
    brave-origin
    zed-editor
    waydroid-helper
    glava
    gdu
    kdePackages.kwallet
    kdePackages.dolphin
    kdePackages.partitionmanager
    gpu-screen-recorder-gtk
    losslesscut-bin
    localsend
    valent
    spotify
    kdePackages.gwenview
    ocamlPackages.gstreamer
    bazaar
    nil
    nixd



    #---------------------------------------------------------------------------
    # Desktop Environment Components & Libraries
    #---------------------------------------------------------------------------

    hyprpolkitagent
    qt6.qtwayland
    qt6.qtbase
    adwaita-icon-theme
    candy-icons
    sweet-folders
    breeze-hacked-cursor-theme
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    qtengine


    #---------------------------------------------------------------------------
    # Customized Media Players
    #---------------------------------------------------------------------------

    (mpv.override {
      scripts = with mpvScripts; [
        mpris
        sponsorblock
        quality-menu
        mpv-playlistmanager
#       modernz
        thumbfast
      ];
    })
  ];
}
