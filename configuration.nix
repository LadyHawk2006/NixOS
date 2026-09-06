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

  time.timeZone = "Africa/Nairobi";

  i18n.defaultLocale = "en_US.UTF-8";

  # ============================================================================
  # User Management & Shell
  # ============================================================================

  users.users."shadrack" = {
    isNormalUser = true;
    description = "Shadrack";
    extraGroups = [ "networkmanager" "wheel" "input" ];
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

  # ============================================================================
  # Desktop Environment & Display Services
  # ============================================================================
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.uwsm.enable = true;

  programs.dms-shell.enable = true;
  programs.dms-shell.package = pkgs.dms-shell;
  programs.nix-ld.enable = true;
  
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
    vscode
    gnome-software
    glava
    kdePackages.kwallet
    kdePackages.dolphin
    kdePackages.partitionmanager
    
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