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
      ./rice.nix
    ];

  nix ={
    binaryCaches = [ "https://cache.nixos.org/"  "https://hydra.iohk.io" ];
    binaryCachePublicKeys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true; 
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };
  


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    version = 2;
    efiSupport = true;
    enableCryptodisk = true;
  };
  
  boot.initrd.luks.devices = [
      {
        name = "root";
        device = "/dev/disk/by-uuid/d45c3463-7bf2-4963-acea-09125a4bb239"; # UUID for /dev/nvme01np2 
        preLVM = true;
        allowDiscards = true;
      }
  ];

  networking.hostName = "shapeshift"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
   environment.systemPackages = with pkgs; [
      # dev
      #vim_configurable
      (import ./vim.nix)
      vimPlugins.vim-obsession
      tmux
      tmuxp
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
      tree
      #screen
      git
      tig
      mosh
      #fish
      vscode
      #alacritty
      ruby
      chruby
      hugs
      python
      python36
      go
      gnumake
      minikube
      kubectl
      ghc
      gcc
      android-studio
      ansible
      dialog
      lxc
      lxd
      #genymotion
      #androidsdk
      #androidsdk_extras
      #dep

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
      cool-old-term
      synapse
      gnome3.gnome-tweak-tool
      arc-kde-theme
      kdeconnect

      # email
      #mutt
      #gnupg
      #gnupg1compat

      # apps
      weechat
      glowing-bear
      typora
      vcv-rack
      renoise
      unstable.google-chrome
      firefox
      gnome3.file-roller
      freemind
      taskwarrior
      timewarrior
      tasksh
      #vit
      #mpv
      #ncmpcpp
      #screenfetch
      #tor-browser-bundle-bin
      #inkscape
      #file
      #wineStaging

      # utils
      wget
      vlc
      chromedriver
      platinum-searcher
      htop
      baobab
      borgbackup
      ntfs3g
      gparted
      file
      citrix_receiver
      bmon
      appimage-run
      #selendroid

      # devops tools
      #gitlab
      #gitlab-runner
      #jenkins

      # crypto altcoins
      bitcoin

      # system
      mkpasswd

      # elk
      #elasticsearch7
      #filebeat7
      #logstash7
      #kibana7
   ];

 
  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  environment.shellAliases = {
    shapeshift = "sudo vim /etc/nixos/configuration.nix";
    rice = "sudo vim /etc/nixos/rice.nix";
    nixpaste = "curl -F \"text=<-\" http://nixpaste.lbr.uno";
    nixos-fix = "nix-store --verify --check-contents --repair";
    nixos-repkg = "nix-build --check -A";
    nixos-clean = "nix-collect-garbage -d";
    nixos-search = "nix-env -qaP --description \\* | sed -re \"s/^nixos\\.//g\" | fgrep -i";
    nixos-update = "nixos-rebuild switch";
    nixos-upgrade = "nixos-rebuild switch --upgrade";
    nxf = "nixos-fix";
    nxr = "nixos-repkg";
    nxc = "nixos-clean";
    nxs = "nixos-search";
    nxu = "nixos-update";
    nxg = "nixos-upgrade"; # TODO: sync git in /etc/nixos/* from imports
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  programs.mtr.enable = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.tmux = {
    enable = true;
    shortcut = "a";
    extraTmuxConf = ''
      set -g @continuum-restore 'on'
      set -g @resurrect-save 'M-s'
      set -g @resurrect-restore 'M-r'
      set -g @resurrect-strategy-vim 'session'
    ''; 
  };
  
  # make vim the default EDITOR
  programs.vim.defaultEditor = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Daemon for loc info
  services.geoclue2.enable = true;

  # Reshift for healthy sleep better circadian stuff and stuff
  services.redshift = {
    enable = true;
    latitude = "40.0";
    longitude = "-83.0";
    provider = "manual";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Elastic Stack
  #services.elasticsearch.enable = true;
  #services.logstash.enable = true;
  #services.kibana.enable = true;

  # Kubernetes
  #services.kubernetes = {
  #  kubelet.extraOpts = "--fail-swap-on=false";
  #  easyCerts = true;
  #  masterAddress = "localhost";
  #  addons.dashboard = {
  #    enable = true;
  #    rbac = {
  #      enable = true;
  #      clusterAdmin = true;
  #    };
  #  };
  #  roles = ["master" "node"];
  #};

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    xrandrHeads = [
      "HDMI-0"
    ];
    #videoDrivers = [ "nvidia" ];
    #synaptics = {
    #  enable = true;
    #  twoFingerScroll = true;
    #  additionalOptions = ''
    #    Option "TapButton2" "3"
    #  '';
    #}; 
  };

  hardware.ledger.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
  };

  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
    lxd.enable = true;
    virtualbox.host.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.mutableUsers = false;
   users.groups.plugdev = {};
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
       "lxd"
       "plugdev"
     ];
     home = "/home/dw";
     createHome = true;
     hashedPassword = "$6$/jq22iSFlUA$K4edOGiK9PYuR8odjJU0o3CFjT0wZ51vNqH01uk8CQ7YuDApnUvLZxgeEWWAp5hJaZeWUbezSPe.FfmJo3jdt/";
     uid = 1000;
   };

  # Autoupgrade
  system.autoUpgrade.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  #system.stateVersion = "17.09"; # Did you read the comment?

}
