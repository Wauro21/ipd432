import csv
import math
from random import randrange
# Generates a golden-reference file for testing in Vitis_hls

default_file_name = "goldenreference"
default_length = 1024
max_number = 256
def main():
    # Define name file
    name_file = input(("Inserte el nombre del archivo sin extension, en caso de querer dejarlo por defecto como: `{}`, presione enter\n").format(default_file_name))
    if(len(name_file) == 0):
        name_file = default_file_name
    # Open file
    file = open(name_file+".csv","w")
    writer = csv.writer(file)

    # Generate "8 bit" values, in reality they are just integers.
    length = input("Ingrese el largo de los vectores, por defecto es:1024\n")
    if(len(length) == 0):
        length = default_length
    else:
        length = int(length)

    for i in range(length):
        A = randrange(max_number)
        B = randrange(max_number)
        row = [A,B]
        writer.writerow(row)
    # Close file
    file.close()

if __name__ == "__main__":
    main()
