#!/bin/tcsh
#rpi_car.sh

raspivid -t 9999999 -hf -vf -fps 15 -o - | nc 192.168.1.129 5001 & sudo python /home/pi/Desktop/quadcopter_peripheral/rpi_car/rc_car_udp.py && fg
