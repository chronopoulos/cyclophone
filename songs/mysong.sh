oscsend 192.168.8.174 8000 "scale" [12,0,2,4]
while true;
do 
oscsend 192.168.8.174 8000 "root" [36,12]
sleep 3  
oscsend 192.168.8.174 8000 "root" [30,12]
sleep 3 ;
done;
 
