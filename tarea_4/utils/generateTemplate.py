# A simple code to generate a ready to insert template of the "eucDis" module

import argparse

def argParser():
    dsc = "By default, the script will search for a template located in the same folder with the name <module_template.txt>, and will save the new template in the same folder with the name <corrected_template.txt>. This behaviour can be overriden by passing arguments to the script"
    parser = argparse.ArgumentParser(description = dsc)
    parser.add_argument("-if", "--InputFile", help= "Indicates which template file to correct. By default it searches for: module_template.txt")
    parser.add_argument("-of","--OutputFile", help = "Indicates where to save the corrected template. By default it's saved to: corrected_template.txt")
    args = parser.parse_args()

    if args.InputFile:
        i_file = str(args.InputFile)
    else:
        i_file = "module_template.txt"
    if args.OutputFile:
        o_file = str(args.OutputFile)
    else:
        o_file = "corrected_template.txt"

    return i_file, o_file

def main():
    inst_template, new_template = argParser()
    file = open(inst_template,"r")
    new_file = open(new_template,"w")
    a_counter = 0
    b_counter = 0
    a_val = "(A[{}])"
    b_val = "(B[{}])"
    for line in file:
        temp = line.strip()
        search_a = '(A_'+str(a_counter)+')'
        search_b = "(B_"+str(b_counter)+")"
        if(search_a in temp):
            new_val = a_val.format(a_counter)
            result = temp.replace(search_a,new_val)
            a_counter +=1
        elif(search_b in line):
            new_val = b_val.format(b_counter)
            result = temp.replace(search_b,new_val)
            b_counter +=1
        else:
            result = temp
        new_file.write(result+"\n")
    file.close()
    new_file.close()
    print("Template generated: {}".format(new_template))
if __name__ == "__main__":
    main()
