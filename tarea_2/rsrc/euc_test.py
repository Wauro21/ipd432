import serial
from random import randrange
# Function to send test data
def send_test(port, n_to_sent, sent):
    for i in range(0,n_to_sent):
        temp_bytes = sent[i].to_bytes(1,"little")
        port.write(temp_bytes)

def wait_response(port, n_to_receive, received):
    for i in range(0, n_to_receive):
        received.append(port.read(1).hex())

def send_command(port, cmd):
    temp_bytes = cmd.to_bytes(1,"little")
    port.write(temp_bytes)

n_to_sent = 8
port = serial.Serial('/dev/ttyUSB1',115200)

#a = [255,255,255,255,255,255,255,255]
b = [1,1,1,1,1,1,1,1]
a = [0,0,0,0,0,0,0,0]

A = []
B = []
send_command(port, 1)
send_test(port, 8,a)
send_command(port, 2)
wait_response(port, 8,A)
send_command(port, 17)
send_test(port, 8,b)
send_command(port, 18)
wait_response(port, 8,B)
print(A)
print(B)

send_command(port, 6)
man = []
wait_response(port,2, man)
print(man)
