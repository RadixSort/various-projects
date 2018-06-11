import RPi.GPIO as io
import sys, tty, termios, time, socket, picamera, picamera.array, numpy

UDP_IP = "192.168.1.122"
UDP_PORT = 10028

UDPsock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
UDPsock.bind((UDP_IP, UDP_PORT))

io.setmode(io.BCM)

M1_E = 16
M1_1 = 20
M1_2 = 21

M2_E = 13
M2_1 = 19
M2_2 = 26

io.setup(M1_1, io.OUT)
io.setup(M1_2, io.OUT)
io.setup(M1_E, io.OUT)

io.setup(M2_1, io.OUT)
io.setup(M2_2, io.OUT)
io.setup(M2_E, io.OUT)

# These two blocks of code configure the PWM settings for
# the 2 DC motors on the car. Starts the PWM and sets the
# motors' speed to 0
motor1 = io.PWM(M1_E,100)
motor1.start(0)
motor1.ChangeDutyCycle(0)

motor2 = io.PWM(M2_E,100)
motor2.start(0)
motor2.ChangeDutyCycle(0)

# The getch method can determine which key has been pressed
# by the user on the keyboard by accessing the system files
# It will then return the pressed key as a variable
def getch():
	fd = sys.stdin.fileno()
	old_settings = termios.tcgetattr(fd)
	try:
		tty.setraw(sys.stdin.fileno())
		ch = sys.stdin.read(1)
	finally:
		termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
	return ch

# This section of code defines the methods used to determine
# whether a motor needs to spin forward or backwards. The
# different directions are acheived by setting one of the
# GPIO pins to true and the other to false. If the status of
# both pins match, the motor will not turn.
def motor1_forward():
	io.output(M1_1, True)
	io.output(M1_2, False)
def motor1_reverse():
	io.output(M1_1, False)
	io.output(M1_2, True)
def motor2_forward():
	io.output(M2_1, True)
	io.output(M2_2, False)
def motor2_reverse():
	io.output(M2_1, False)
	io.output(M2_2, True)

# This method will toggle the direction of the steering
# motors. The method will determine whether the user wants
# to got left/right/fwd/bwd depending on the key they press then
# then make the appropriate adjustment. It works as a toggle
# because the program cannot read multiple pressed keys at
# the same time. It will then update the status of the wheel 
# to access next time it is called.
def toggleSteering(direction):
	global wheelStatus
	if(direction == "right"):
		if(wheelStatus == "centre"):
			motor1_forward()
			motor1.ChangeDutyCycle(99)
			wheelStatus = "right"
		elif(wheelStatus == "left"):
			motor1.ChangeDutyCycle(0)
			wheelStatus = "centre"
	if(direction == "left"):
		if(wheelStatus == "centre"):
			motor1_reverse()
			motor1.ChangeDutyCycle(99)
			wheelStatus = "left"
		elif(wheelStatus == "right"):
			motor1.ChangeDutyCycle(0)
			wheelStatus = "centre"

def toggleMovement(direction):
	global movement
	global flag
	if(direction == "forward"):
		if(movement == "centre"):
			motor2_forward()
			motor2.ChangeDutyCycle(99)
			movement = "forward"
		elif(movement == "backward"):
			motor2.ChangeDutyCycle(0)
			movement = "centre"
	if(direction == "backward"):
		if(movement == "centre"):
			motor2_reverse()
			motor2.ChangeDutyCycle(99)
			movement = "backward"
		elif(movement == "forward"):		
			motor2.ChangeDutyCycle(0)
			movement = "centre" 

# Setting the PWM pins to false so the motors will not move
# until the user presses the first key
io.output(M1_1, False)
io.output(M1_2, False)
io.output(M2_1, False)
io.output(M2_2, False)

# Global variable initilaize
wheelStatus = "centre"
movement = "centre"
flag = 0

# Instructions for when the user has an interface
print("w/s: acceleration")
print("a/d: steering")
print("x: exit")

# Infinite loop that will not end until the user presses the
# exit key
while True:

	# Keyboard character retrieval method is called and saved
	# into variable
	char = getch()
	if(char == "w"):
		toggleMovement("forward")
	if(char == "s"):
		toggleMovement("backward")
	if(char == "a"):
		toggleSteering("left")
	if(char == "d"):
		toggleSteering("right")
	if(char == "x"):
		print("Program Ended")
		break

	# Receive mode invoked by "r", tries to retrieve UDP packets
	# from DE2 and perform commands accordingly
	if(char == "r"):
		while(1):
			print("Trying to receive UDP packet...")
			data, addr = UDPsock.recvfrom(1024)
			print("Received:", data)

			for i in range (0,len(data)):
				if(data[i] == "w"):
					toggleMovement("forward")
				elif(data[i] == "s"):
					toggleMovement("backward")
				elif(data[i] == "a"):
					toggleSteering("left")
				elif(data[i] == "d"):
					toggleSteering("right")
				elif(data[i] == "x"):
					print('Returning to manual mode...')
					flag = 1
					break
			if (flag == 1):
				flag = 0
				break

	# Send mode invoked by "t", sends UDP packets to the DE2 that
	# consist of one frame's worth of RGB values stored in an array
	# 100(width) * 100(height) *3(R,G,B) = 30,000 bytes
	if(char == "t"):
		print("Sending packets to DE2....")
		with picamera.PiCamera() as camera:
    			with picamera.array.PiRGBArray(camera) as stream:
  	    			camera.resolution = (100,100)
      				camera.capture(stream, 'rgb')
      				x = numpy.extract(numpy.mod(stream.array, 1)==0, stream.array)
      				UDPsock.sendto(bytearray(x), (UDP_IP, UDP_PORT))

	# At the end of each loop the acceleration motor will stop
	# and wait for its next command
	# motor2.ChangeDutyCycle(0)

	# The keyboard character variable will be set to blank, ready
	# to save the next key that is pressed
	char = ""
	
io.cleanup()
