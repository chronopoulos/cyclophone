{ haskellPackages ? (import <nixpkgs> {}).haskellPackages }:
let
  inherit (haskellPackages) cabal hosc cabalInstall_1_18_0_3;

in cabal.mkDerivation (self: {
  pname = "oscsend";
  version = "1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  buildDepends = [
    # As imported above
    hosc 
  ];
  buildTools = [ cabalInstall_1_18_0_3 ];
  enableSplitObjs = false;
  meta = {
    description = "send an osc message from the command line";
    license = self.stdenv.lib.licenses.gpl3;
    platforms = self.ghc.meta.platforms;
  };
})


