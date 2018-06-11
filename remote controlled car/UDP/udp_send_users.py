import socket, time
import msvcrt

UDP_IP = "192.168.1.122" # CHANGE
UDP_PORT = 10028 # CHANGE

print "UDP target IP:", UDP_IP
print "UDP target port:", UDP_PORT

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

print('Remote Controlled Surveillance Vehicle')
print('\rRemote Controlled Surveillance Vehicle...Online.')


print('--------RC Surveillance Vehicle Control Panel--------')
print('Press Keys for Motor Behaviour.')
print('W: Forward Motor Acceleration')
print('S: Backwards Motor Acceleration')
print('A: Left Steer')
print('D: Right Steer')
print('X: Exit script')
print('-----------------------------------------------------')


while True:
	user_input = raw_input('Please enter desired motor behaviour:')
	sock.sendto(user_input, (UDP_IP, UDP_PORT))
	print('Sending...', user_input)
	if (user_input == "x"):
		print('Exiting python script...')
		break;
