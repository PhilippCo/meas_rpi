import pyvisa
rm = pyvisa.ResourceManager('@py')

inst = rm.open_resource("GPIB0::23::INSTR")
print(inst.read())
