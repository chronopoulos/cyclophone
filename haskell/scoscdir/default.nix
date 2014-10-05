{ cabal, filepath, hosc, hsc3, multimap, prettyShow, split
, systemFilepath, text
}:

cabal.mkDerivation (self: {
  pname = "scoscdir";
  version = "0.1.0.0";
  src=./.;
  isLibrary = false;
  isExecutable = true;
  buildDepends = [
    filepath hosc hsc3 multimap prettyShow split systemFilepath text
  ];
  meta = {
    description = "manage and play multiple directories of samples based on cyclophone osc messages";
    license = self.stdenv.lib.licenses.unfree;
    platforms = self.ghc.meta.platforms;
  };
})
