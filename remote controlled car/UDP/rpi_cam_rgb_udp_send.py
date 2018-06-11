import time, picamera, picamera.array, socket, numpy

UDP_IP = "192.168.1.122"
UDP_PORT = 10027

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

while 1:
  with picamera.PiCamera() as camera:
    with picamera.array.PiRGBArray(camera) as stream:
      camera.resolution = (50,50)
      #camera.start_preview()
      #time.sleep(5)
      camera.capture(stream, 'rgb')
      x = numpy.extract(numpy.mod(stream.array, 1)==0, stream.array)
      print(x)
      sock.sendto(bytearray(x), (UDP_IP, UDP_PORT))
