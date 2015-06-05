{ cabal, hosc, ioctl, prettyShow, serial, spidevice, time }:

cabal.mkDerivation (self: {
  pname = "keyosc";
  version = "0.1.0.0";
  src=.\.;
  isLibrary = false;
  isExecutable = true;
  buildDepends = [ hosc ioctl prettyShow serial time ];
  extraLibraries = [ spidevice ];
  meta = {
    homepage = "https://github.com/chronopoulos/cyclophone";
    description = "detect cyclophone key presses, send out osc messages";
    license = self.stdenv.lib.licenses.gpl3;
    platforms = self.ghc.meta.platforms;
  };
})
