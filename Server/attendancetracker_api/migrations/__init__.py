import qrcode
import os

import requests

current_file_path = os.path.realpath('__file__')
server_path = os.path.dirname(os.path.abspath(current_file_path))
ip_address_path = server_path + '\\ipv4_addrs.txt'
ip_addresses = ""

try:
    # setup a server to listen to requests
    with open(ip_address_path, "r") as file:
        ip_addresses = file.readline().strip()

    if ip_addresses == "" or ip_addresses == None:
        print("No IP address found in the file.")
except FileNotFoundError:
    print("File not found. Make sure 'ip_address.txt' exists.")
except Exception as e:
    print("An error occurred:", str(e))
img = qrcode.make(ip_addresses)
img.show()