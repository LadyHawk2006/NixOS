{ config, pkgs, ... }:


{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "xpad" "uinput" ];


  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.firewall.trustedInterfaces = [ "waydroid0" ];
  time.timeZone = "Africa/Nairobi";

  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."shadrack" = {
    isNormalUser = true;
    description = "Shadrack";
    extraGroups = [ "networkmanager" "wheel" "input" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "hyprland";
  };

hardware.bluetooth.enable = true;
hardware.xone.enable = true; # Adds enhanced Xbox controller drivers/rules


services.acpid.enable = true;
services.blueman.enable = true;
services.upower.enable = true;
services.printing.enable = true;
services.gvfs.enable = true;
services.udisks2.enable = true;
services.flatpak.enable = true;
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


virtualisation.waydroid.enable = true;
virtualisation.waydroid.package = pkgs.waydroid-nftables;

programs.hyprland = {
   enable = true;
   xwayland.enable = true;
 };

xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.dms-shell.enable = true;
  programs.dms-shell.package = pkgs.dms-shell;
  programs.uwsm.enable = true;
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    ghostty
    nautilus
    gapless
    amberol
    google-chrome
    git
    hyprpolkitagent
    wl-clipboard
    libnotify
    eza
    qt6.qtwayland
    qt6.qtbase
    vscode
    keyd
    kdePackages.kwallet
    kdePackages.dolphin
    wev
    usbutils
    fastfetch
    gnome-software
    glava
    yt-dlp
    android-tools
    scrcpy
    uv
    localsend
    tangram
    python3
    brightnessctl
    ffmpegthumbnailer
    playerctl
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


 environment.sessionVariables = {
   QT_QPA_PLATFORM = "wayland;xcb";
   NIXOS_OZONE_WL = "1";
 };

 fonts.packages = with pkgs; [
   nerd-fonts.fira-code
   nerd-fonts.jetbrains-mono
   font-awesome
   noto-fonts-color-emoji
 ];

  system.stateVersion = "26.05"; # Did you read the comment?

}