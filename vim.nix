with import <nixpkgs> {};

vim_configurable.customize {
  name = "vim";
  # Use the default plugin list shipped with nixpkgs
  vimrcConfig.vam.knownPlugins = pkgs.vimPlugins;
  vimrcConfig.vam.pluginDictionaries = [
    { 
      names = [
        # Here you can place all your vim plugins
        # They are installed managed by `vam` (a vim plugin manager)
        "Syntastic"
        "ctrlp"
      ];
    }
  ];
}
