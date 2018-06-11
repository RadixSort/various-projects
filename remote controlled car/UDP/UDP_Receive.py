# Client

import select, socket

port = 10028
bufferSize = 1024

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(('',port))
sock.setblocking(0)

while True:
  result = select.select([sock],[],[])
  msg = result[0][0].recv(bufferSize)
  print msg
