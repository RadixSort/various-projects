import socket

UDP_IP = "192.168.1.122"
UDP_PORT = 37
MESSAGE = "Hello, World! Youngjin Sucks"

print "UDP target IP:", UDP_IP
print "UDP target port:", UDP_PORT
print "Message:", MESSAGE

x = [0xEEEEEEEEEE, 0x4c4f4c53, 0xAA, 0xBBBB)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.sendto(bytearray(x), (UDP_IP, UDP_PORT))
