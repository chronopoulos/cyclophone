#screen -d -m ~/.cabal/bin/scoscdir 192.168.8.121 8000 ~/cyclophone_samples/mmap.hs
#screen -d -m ~/.cabal/bin/scoscdir 192.168.8.174 8000 ~/cyclophone_samples/sine.hs
#screen -d -m ~/.cabal/bin/scoscdir 127.0.0.1 8000 ~/cyclophone_samples/mmap.hs
#screen -d -m '~/.cabal/bin/scoscdir 127.0.0.1 8000 ~/cyclophone_samples/mmap.hs 127.0.0.1 8086 2>&1 /home/pi/scoscdir1.txt'
# '~/.cabal/bin/scoscdir 127.0.0.1 8000 ~/cyclophone_samples/mmap.hs 127.0.0.1 8086 &> ~/scoscdir1.txt'
#'~/.cabal/bin/scoscdir 127.0.0.1 8000 ~/cyclophone_samples/mmap.hs 127.0.0.1 8086'
#screen -d -m ~/.cabal/bin/scoscdir 127.0.0.1 8000 ~/cyclophone_samples/mmap.hs 127.0.0.1 8086 &> ~/scoscdir1.txt

screen -d -m ~/.cabal/bin/scoscdir 127.0.0.1 8000 ~/cyclophone_samples/mmap.hs 127.0.0.1 8086
