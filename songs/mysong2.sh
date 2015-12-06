oscsend 192.168.10.143 8000 "scale" [12,0,2,4]
while true;
do 
oscsend 192.168.10.143 8000 "scale" [12,0,2,4,7]
oscsend 192.168.10.143 8000 "root" [36,12]
sleep 1  
oscsend 192.168.10.143 8000 "scale" [12,0,2,4,6]
oscsend 192.168.10.143 8000 "root" [34,12]
sleep 1 
oscsend 192.168.10.143 8000 "scale" [12,0,3,4,6]
oscsend 192.168.10.143 8000 "root" [32,12]
sleep 1 
done;
 
