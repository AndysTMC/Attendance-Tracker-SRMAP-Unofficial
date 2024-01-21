import qrcode
import os

current_file_path = os.path.realpath('__file__')
server_path = os.path.dirname(os.path.abspath(current_file_path))
ip_address_path = server_path + '\\ip_address.txt'
ip_address = ""

try:
    with open(ip_address_path, "r") as file:
        ip_address = file.readline().strip()
    if ip_address == "" or ip_address == None:
        print("No IP address found in the file.")
except FileNotFoundError:
    print("File not found. Make sure 'ip_address.txt' exists.")
except Exception as e:
    print("An error occurred:", str(e))
img = qrcode.make(ip_address)

img.show()