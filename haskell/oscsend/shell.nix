let pkgs = import <nixpkgs> {};
    haskellPackages = pkgs.haskellPackages.override {
      extension = self: super: {
        oscsend = self.callPackage ./. {};
      };
    };
 in pkgs.lib.overrideDerivation haskellPackages.oscsend (attrs: {
   buildInputs = [ haskellPackages.cabalInstall ] ++ attrs.buildInputs;
 })
