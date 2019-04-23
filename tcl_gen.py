basestr = """
# 
# connection point ATTACK
# 
add_interface ATTACK conduit end
set_interface_property ATTACK associatedClock CLK
set_interface_property ATTACK associatedReset RESET
set_interface_property ATTACK ENABLED true
set_interface_property ATTACK EXPORT_OF ""
set_interface_property ATTACK PORT_NAME_MAP ""
set_interface_property ATTACK CMSIS_SVD_VARIABLES ""
set_interface_property ATTACK SVD_ADDRESS_GROUP ""

add_interface_port ATTACK ATTACK attack Output 16

"""

interfaces = ["ATTACK", "RLEASE", "SUSTAIN", "DECAY", "SHAPE1", "SHAPE0"]
widths = ["16", "16", "16", "16", "2", "2"]

voices = 4

for i in range(voices):
    interfaces.append("FREQ" + str(i))
    widths.append("8")
    interfaces.append("KEY"+str(i))
    widths.append("1")
    interfaces.append("AMP1_"+str(i))
    widths.append("16")
    interfaces.append("AMP0_"+str(i))
    widths.append("16")

for i in range(len(interfaces)):
    print(basestr.replace("ATTACK", interfaces[i]).replace("16", widths[i]).replace("attack", interfaces[i].lower()))


