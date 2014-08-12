{ haskellPackages ? (import <nixpkgs> {}).haskellPackages }:
let
  inherit (haskellPackages) cabal filepath hosc hsc3 multimap prettyShow split
    systemFilepath text cabalInstall_1_18_0_3;

in cabal.mkDerivation (self: {
  pname = "scoscdir";
  version = "1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  buildDepends = [
    # As imported above
    filepath hosc hsc3 multimap prettyShow split
    systemFilepath text 
  ];
  buildTools = [ cabalInstall_1_18_0_3 ];
  enableSplitObjs = false;
  meta = {
    description = "send an osc message from the command line";
    license = self.stdenv.lib.licenses.gpl3;
    platforms = self.ghc.meta.platforms;
  };
})


