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
    extraInitrd = /boot/initrd.keys.gz;
  };
  
  boot.initrd.luks.devices = [
      {
        name = "root";
        device = "/dev/disk/by-uuid/18d1ae63-a541-4f1d-8c01-28cade131368"; # UUID for /dev/nvme01np2 
        preLVM = true;
        keyFile = "/keyfile0.bin";
        allowDiscards = true;
      }
  ];

  # Data mount
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/5df4931a-e4c8-42a9-9974-92dc2a9db84d"; # UUID for /dev/mapper/crypted-data
    encrypted = {
      enable = true;
      label = "crypted-data";
      blkDev = "/dev/disk/by-uuid/a65d2830-5a86-400c-817a-4ee8adcf1e1e"; # UUID for /dev/sda1
      keyFile = "/keyfile1.bin";
    };
  };

  networking.hostName = "shapeshift"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
   environment.systemPackages = with pkgs; [
     # The chosen packages
     # if it's not essential 'nix' it (as in remove it :0)
     # The 'Friendly Interactive Shell' -- "Finally, a shell for the 90's!"
     fish
     vim
     git
     lynx
     firefox
     vscode
     synapse

     # TODO extract to fun module
     cool-retro-term
   ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
    virtualbox.host.enable = true;
  };

  services.xserver.desktopManager.gnome3.enable = true;  

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
