# ./target/release/cyclosim 127.0.0.1:5432 192.168.8.180:8000 127.0.0.1:9555
screen -dmS cyclosim sh -c "./target/debug/cyclosim 0.0.0.0:5432 0.0.0.0:8000 0.0.0.0:9555"

screen -dmS oscpad sh -c "oscpad cycloconfig.json"

