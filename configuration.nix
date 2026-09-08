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
  # System & Boot
  # ============================================================================

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "xpad" "uinput" ];

  system.stateVersion = "26.05";

  # ============================================================================
  # Networking & Localization
  # ============================================================================

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.firewall.trustedInterfaces = [ "waydroid0" ];


  networking.firewall = {
    enable = true;
    
    allowedTCPPorts = [ 
      53317 # LocalSend
      5555  # Default ADB Wireless
      8080
    ];
    
    allowedUDPPorts = [ 
      53317
      8080 # LocalSend
    ];

    allowedTCPPortRanges = [ { from = 30000; to = 50000; } ];
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
  # Nixpkgs Configuration
  # ============================================================================

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
    KERNEL=="event*", NAME="input/%k", MODE="0666"
  '';

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "c0f4:10f5" ]; # Your USB keyboard ID
        settings = {
          main = {
            f4 = "media";
            f5 = "playpause";
            f6 = "command(playerctl previous)";
            f7 = "command(playerctl next)";
            f8 = "volumedown";
            f9 = "volumeup";
            f10 = "mute";
          };
        };
      };
    };
  };

  services.openssh.enable = true;

  services.minidlna = {
  enable = true;
  openFirewall = true;
  settings = {
    media_dir = [ "V,/home/shadrack/Videos" ];
    friendly_name = "NixOS Media";
    inotify = "yes"; 
  };
 };

systemd.services.minidlna.serviceConfig.ProtectHome = "read-only";

#  services.samba = {
#  enable = true;
#  openFirewall = true; # Automatically opens required SMB ports
#  settings = {
#    global = {
#      "workgroup" = "WORKGROUP";
#      "server string" = "NixOS Media";
#      "netbios name" = "nixos";
#      "security" = "user";
#    };
#    "Videos" = {
#      "path" = "/home/shadrack/Videos";
#      "browseable" = "yes";
#      "read only" = "yes";
#      "guest ok" = "no";
#    };
#  };
#};

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

  # ============================================================================
  # Fonts
  # ============================================================================
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    font-awesome
    noto-fonts-color-emoji
  ];

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
    localsend
    ffmpeg
    python3
    brightnessctl
    steam-run
    ffmpegthumbnailer
    playerctl
    keyd

    #---------------------------------------------------------------------------
    # Terminal & GUI Applications
    #---------------------------------------------------------------------------

    ghostty
    nautilus
    gapless
    amberol
    google-chrome
    brave-origin
    caddy
    nodejs
    vscode
    gnome-software
    glava
    kdePackages.kwallet
    kdePackages.dolphin
    kdePackages.partitionmanager
    easyeffects
    bat
    gpu-screen-recorder-gtk
    
    #---------------------------------------------------------------------------
    # Desktop Environment Components & Libraries
    #---------------------------------------------------------------------------

    hyprpolkitagent
    qt6.qtwayland
    qt6.qtbase
    
    #---------------------------------------------------------------------------
    # Customized Media Players
    #---------------------------------------------------------------------------

    (mpv.override {
      scripts = with mpvScripts; [
        mpris
        sponsorblock
        quality-menu
        mpv-playlistmanager
        modernz
        thumbfast
      ];
    })
  ];
}