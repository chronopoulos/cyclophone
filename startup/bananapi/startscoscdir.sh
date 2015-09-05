#screen -d -m ~/.cabal/bin/scoscdir 192.168.8.121 8000 ~/cyclophone_samples/mmap.hs
#screen -d -m ~/.cabal/bin/scoscdir 192.168.8.174 8000 ~/cyclophone_samples/sine.hs
#screen -d -m ~/.cabal/bin/scoscdir 127.0.0.1 8000 ~/cyclophone_samples/mmap.hs
#screen -d -m '~/.cabal/bin/scoscdir 127.0.0.1 8000 ~/cyclophone_samples/mmap.hs 127.0.0.1 8086 2>&1 /home/pi/scoscdir1.txt'
# '~/.cabal/bin/scoscdir 127.0.0.1 8000 ~/cyclophone_samples/mmap.hs 127.0.0.1 8086 &> ~/scoscdir1.txt'
#'~/.cabal/bin/scoscdir 127.0.0.1 8000 ~/cyclophone_samples/mmap.hs 127.0.0.1 8086'
#screen -d -m ~/.cabal/bin/scoscdir 127.0.0.1 8000 ~/cyclophone_samples/mmap.hs 127.0.0.1 8086 &> ~/scoscdir1.txt


#screen -d -m session sh -c '~/.cabal/bin/scoscdir 127.0.0.1 8000 ~/cyclophone_samples/mmap.hs 127.0.0.1 8086 ; read x'

#screen -d -m session sh -c 'echo hello ; read x'

#screen -d -m ~/.cabal/bin/scoscdir 127.0.0.1 8000 ~/cyclophone_samples/mmap.hs 127.0.0.1 8086

# pre 2015-02-02
# screen -d -m ~/.cabal/bin/scoscdir 192.168.8.174 8000 ~/cyclophone_samples/mmap.hs 192.168.8.174 8086

# debug by writing to logs.  but, doesn't seem to write anything.
# screen -d -m ~/.cabal/bin/scoscdir 192.168.8.174 8000 ~/cyclophone_samples/mmap.hs 192.168.8.174 8086 > /home/pi/scoscdirout.txt 2>&1

screen -d -m ~/.cabal/bin/scoscdir 192.168.8.180 8000 ~/cyclophone_samples/mmap.hs 192.168.8.180 8086 

# foo > allout.txt 2>&1
