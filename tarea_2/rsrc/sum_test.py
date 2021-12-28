import serial
from random import randrange
# Function to send test data
def send_test(port, n_to_sent, sent):
    for i in range(0,n_to_sent):
        temp = randrange(256)
        temp_bytes = temp.to_bytes(1,"little")
        sent.append(temp_bytes.hex())
        port.write(temp_bytes)

def wait_response(port, n_to_receive, received):
    for i in range(0, n_to_receive):
        received.append(port.read(1).hex())

def send_command(port, cmd):
    temp_bytes = cmd.to_bytes(1,"little")
    port.write(temp_bytes)

def check_values(sent, received):
    #Data check strings
    lost = "Data Lost? : {status}"
    integrity = "Data integrity?: {result}"
    if(len(sent) == len(received) == n_to_sent):
        print(lost.format(status="NO"))
        data_integrity = "Failed at {byte} byte"
        integrity_check = "FAILED"
        for i in range(0,n_to_sent):
            if(sent[i] != received[i]):
                print("\t"+data_integrity.format(byte=i))
            else:
                integrity_check = "OK"
        print(integrity.format(result=integrity_check))

    else:
        print(lost.format(status="YES, stopping test"))

n_to_sent = 8
port = serial.Serial('/dev/ttyUSB1',115200)
#serial.EIGHTBITS, serial.PARITY_NONE, serial.STOPBITS_ONE, 1,serial.XON

sent_a = []
received_a = []
sent_b = []
received_b = []
suma = []
calculado = []
send_command(port, 1)
send_test(port, n_to_sent, sent_a)
send_command(port, 17)
send_test(port, n_to_sent, sent_b)
send_command(port, 18)
wait_response(port,n_to_sent,received_b)
send_command(port, 2)
wait_response(port,n_to_sent,received_a)
print("RX_COMPLETED!")
print("A - Block check")
check_values(sent_a, received_a)
print("B - Block check")
check_values(sent_b, received_b)

send_command(port, 3)
wait_response(port, 2*n_to_sent,suma)
print("RECIBIDO")
print(suma)
print("CALCULADO")
for i in range(len(sent_a)):
    calculado.append(hex(int(sent_a[i],16)+int(sent_b[i],16)))
print(calculado)
