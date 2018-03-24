# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./elk.nix
    ];

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true; 
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

   networking.hostName = "shapeshift"; # Define your hostname.
   networking.networkmanager.enable = true;

  # Select internationalisation properties.
   i18n = {
     consoleFont = "Lat2-Terminus16";
     consoleKeyMap = "us";
     defaultLocale = "en_US.UTF-8";
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
      unstable.google-chrome
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

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    version = 2;
    efiSupport = true;
    extraInitrd = "/boot/initrd.keys.gz";
  }

  # Grub menu is painted really slowly on HiDPI, so we lower the
  # resolution. Unfortunately, scaling to 1280x720 (keeping aspect
  # ratio) doesn't seem to work, so we just pick another low one.
  # boot.loader.grub.gfxmodeEfi = "1024x768";

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/63a66883-c104-4307-a4db-4afe908f3e84"; # UUID for /dev/nvme01np2
      preLVM = true;
      keyFile = "/keyfile0.bin";
      allowDiscards = true;
    }
  ];

  # Data mount
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/f2c17687-f377-40e3-beda-63692f0c9fe0"; # UUID for /dev/mapper/crypted-data
    encrypted = {
      enable = true;
      label = "crypted-data";
      blkDev = "/dev/disk/by-uuid/16110e14-60fa-4a3e-b49a-fa785c627ccf"; # UUID for /dev/sda1
      keyFile = "/keyfile1.bin";
    };  
  }

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
    libvirtd.enable = true;
    docker.enable = true;
    virtualbox.host.enable = true;
  };

  services = {
    elk = {
      enable = true;
      systemdUnits = [ "kibana" "gitlab" "jenkins" "postgres" ];
    };
    postgresql = {
      enable = true;
      package = pkgs.postgresql94;
    };
    logind.lidSwitch = "ignore";
    xserver = {
      enable = true;
      autorun = true;
      # Enable touchpad support.
      libinput.enable = true;
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

  nix = {
    trustedBinaryCaches = [ https://cache.nixos.org https://hydra.iohk.io ];
    binaryCachePublicKeys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
  };

  # aliases
  programs.fish.shellAliases = {
    shapeshift = "pushd .; and cd /etc/nixos; and sudo vim .; and popd";
    vi = "vim";
    lsblk = "lsblk -o MODEL,VENDOR,NAME,LABEL,SIZE,MOUNTPOINT,FSTYPE";
    gramps = "nix-env -p /nix/var/nix/profiles/system --list-generations";
    nixos-rebuild = "nixos-rebuild -j 6 --cores 8";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.mutableUsers = false;
   users.extraUsers.dw = {
     isNormalUser = true;
     extraGroups = [
       "audio"
       "wheel"
       "networkmanager"
       "libvirtd"
       "vboxusers"
       "dialout"
       "docker"
     ];
     home = "/home/dw";
     createHome = true;
     shell = pkgs.fish;
     hashedPassword = "$6$/jq22iSFlUA$K4edOGiK9PYuR8odjJU0o3CFjT0wZ51vNqH01uk8CQ7YuDApnUvLZxgeEWWAp5hJaZeWUbezSPe.FfmJo3jdt/";
     uid = 1000;
   };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09"; # Did you read the comment?

}
