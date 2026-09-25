{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.dms.homeModules.dank-material-shell ];

  home.stateVersion = "26.05";
  home.username = "shadrack";
  home.homeDirectory = "/home/shadrack";

  # ============================================================================
  # Programs & Services
  # ============================================================================
  programs.dank-material-shell = {
    enable = true;
  };

  programs.fish = {
    enable = true;
  };

  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      mpris
      sponsorblock
      quality-menu
      mpv-playlistmanager
      thumbfast
    ];
  };

  # ============================================================================
  # Session Variables & Theming
  # ============================================================================
  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb";
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "iHD";
  };

  home.sessionPath = [ "$HOME/.local/bin" ];


  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
  };

  # ============================================================================
  # User Packages
  # ============================================================================
  home.packages = with pkgs; [
    # Applications
    bazaar
    google-chrome
    gpu-screen-recorder-gtk
    localsend
    proton-vpn
    spotify
    zed-editor

    # Utilities & Media
    bat
    eza
    fastfetch
    gapless
    gdu
    ghostty
    glava
    grimblast
    kdePackages.dolphin
    kdePackages.gwenview
    kdePackages.partitionmanager
    nautilus
    playerctl
    scrcpy
    vim
    yt-dlp

    # Development
    nil
    nixd
    ocamlPackages.gstreamer
    gitleaks

    # Theming & Visuals
    adwaita-icon-theme
    breeze-hacked-cursor-theme
    candy-icons
    hyprpolkitagent
    sweet-folders
    quick-webapps
  ];
}
