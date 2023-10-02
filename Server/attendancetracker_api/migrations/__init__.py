import qrcode

# get ip of the machine
import socket
hostname = socket.gethostname()
ip_address = socket.gethostbyname(hostname)

# Create QR code instance
img = qrcode.make(ip_address)

# Show the QR code
img.show()