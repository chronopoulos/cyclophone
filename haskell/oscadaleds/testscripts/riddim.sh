while [ 1 ]; do 
  oscsend 127.0.0.1 8086 fadeto [1,15]
  oscsend 127.0.0.1 8086 fadeto [0,15]
  sleep .5
done
