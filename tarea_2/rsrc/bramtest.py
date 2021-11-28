import serial
from random import randrange
# Function to send test data
def send_test(port, n_to_sent, sent):
    for i in range(0,n_to_sent):
        temp = randrange(256)
        temp_bytes = temp.to_bytes(1,"little")
        sent.append(temp_bytes.hex())
        port.write(temp_bytes)

def wait_response(port, n_to_receive, recieved):
    for i in range(0, n_to_receive):
        received.append(port.read(1).hex())


n_to_sent = 1024
port = serial.Serial('/dev/ttyUSB1',115200)
#serial.EIGHTBITS, serial.PARITY_NONE, serial.STOPBITS_ONE, 1,serial.XON

sent = []
received = []
#Data check strings
lost = "Data Lost? : {status}"
integrity = "Data integrity?: {result}"
send_test(port,n_to_sent,sent)
wait_response(port,n_to_sent, received)

print("RX_COMPLETED!")
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
