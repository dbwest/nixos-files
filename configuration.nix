# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

   networking.hostName = "shapeshift"; # Define your hostname.
   networking.networkmanager.enable = true;

  # Select internationalisation properties.
   i18n = {
     consoleFont = "Lat2-Terminus16";
     consoleKeyMap = "us";
     defaultLocale = "en_US.UTF-8";
   };

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true; 
  };

  # Set your time zone.
   time.timeZone = "America/New_York";

  environment = {
    shells = [
      "${pkgs.bash}/bin/bash"
      "${pkgs.fish}/bin/fish"
    ];
    variables = {
      BROWSER = pkgs.lib.mkOverride 0 "chromium";
      EDITOR = pkgs.lib.mkOverride 0 "vim";
    };
    systemPackages = with pkgs; [
      # $ nix-env -qaP | grep wget to find packages

      # dev
      vim_configurable
      tmux
      tree
      screen
      git
      mosh
      fish
      vscode
      alacritty 
      ruby 
      chruby 
      hugs 
      python
      python36
      go
      dep
      gnumake
      minikube
      #kubectl
      ghc 
      gcc 
      git 

      # desktop
      gnome3.gnome_terminal
      gnome3.gnome-screenshot
      gnome3.nautilus
      gnome3.eog
      gnome3.dconf
      i3lock-color
      feh
      rofi
      numix-gtk-theme
      numix-icon-theme
      lxappearance
      #gnome-tweak-tool

      # email
      mutt
      gnupg
      gnupg1compat

      # apps
      mpv
      ncmpcpp
      screenfetch
      chromium
      firefox
      tor-browser-bundle-bin
      inkscape
      file
      wineStaging
      gnome3.file-roller
      freemind 

      # utils
      wget 
      vlc 
      chromedriver 
      platinum-searcher 

      # devops tools
      gitlab 
      gitlab-runner 
      jenkins 
      buildbot 
      buildbot-worker

      # crypto altcoins
      bitcoin 

      # system
      mkpasswd
    ];
  };

  # Supposedly better for the SSD.
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Grub menu is painted really slowly on HiDPI, so we lower the
  # resolution. Unfortunately, scaling to 1280x720 (keeping aspect
  # ratio) doesn't seem to work, so we just pick another low one.
  # boot.loader.grub.gfxmodeEfi = "1024x768";

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/d0c4dacb-8fbb-4646-a0e1-0d1eb8266321";
      preLVM = true;
      allowDiscards = true;
    }
  ];

  networking.firewall.allowedTCPPorts = [ 22 80 ];

  fonts = {
    enableCoreFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = false;
    fonts = [
       pkgs.terminus_font_ttf
       pkgs.tewi-font
       pkgs.kochi-substitute-naga10
       pkgs.source-code-pro
    ];
  };
  
  programs = {
    bash = {
      enableCompletion = true;
    };
    ssh = {
      startAgent = true;
    };
  };

  virtualisation = {
    libvirtd.enable = false;
    docker.enable = true;
    virtualbox.host.enable = true;
  };

  services = {
    logind.lidSwitch = "ignore";
    xserver = {
      enable = true;
      autorun = true;
      # Enable touchpad support.
      libinput.enable = true;
      displayManager.lightdm.enable = true;
      desktopManager.gnome3.enable = true;
      # videoDrivers = [ "nvidia" ];
      layout = "us";
    };
    # Enable CUPS to print documents.
    printing.enable = true;
    openssh = {
      enable = true;
    };
    redshift = {
      enable = true;

      # Columbus, OH USA
      latitude = "40.001633";
      longitude = "-81.019707";
    };
    mpd = {
      enable = true;
      user = "dw";
      group = "users";
      musicDirectory = "/home/dw/Music";
      dataDir = "/home/dw/.mpd";
      extraConfig = ''
          audio_output {
            type    "pulse"
            name    "Local MPD"
            server  "127.0.0.1"
          }
        '';
    };
  };

  hardware = {
    trackpoint.emulateWheel = true;

    # for steam
    #opengl.driSupport32Bit = true;

    pulseaudio = {
      enable = true;
      systemWide = true;
      support32Bit = true;
      tcp = {
        enable = true;
        anonymousClients = {
          allowedIpRanges = [ "127.0.0.1" ];
        };
      };
    };
  };
  
  # aliases
  environment.interactiveShellInit = ''
    alias shapeshift="pushd && cd /etc/nixos && vim ."
    alias vi=vim
    alias lsblk="lsblk -o MODEL,VENDOR,NAME,LABEL,SIZE,MOUNTPOINT,FSTYPE";
    alias gramps="nix-env -p /nix/var/nix/profiles/system --list-generations";
    alias nixos-rebuild="nixos-rebuild -j 6 --cores 8";
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.mutableUsers = false;
   users.extraUsers.dw = {
     isNormalUser = true;
     extraGroups = [
       "wheel"
       "networkmanager"
       "libvirtd"
       "vboxusers"
       "dialout"
       "docker"
     ];
     home = "/home/dw";
     createHome = true;
     useDefaultShell = true;
     hashedPassword = "$6$/jq22iSFlUA$K4edOGiK9PYuR8odjJU0o3CFjT0wZ51vNqH01uk8CQ7YuDApnUvLZxgeEWWAp5hJaZeWUbezSPe.FfmJo3jdt/";
     uid = 1000;
   };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09"; # Did you read the comment?

}
