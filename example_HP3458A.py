# Just a plain python example.

# The idea of this package is to use Jupyter Lab instead of plain python files

# Start your Browser and go to http://<raspi-IP>:8888
# or if you are using a GUI on your Pi http://localhost:8888

# the password is 1281


import pyvisa
rm = pyvisa.ResourceManager('@py')

inst = rm.open_resource("GPIB0::22::INSTR")

inst.write("END ALWAYS")

print(inst.query("ID?"))

#get reading
print(inst.read())
