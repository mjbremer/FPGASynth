import math
import matplotlib.pyplot as plt
from binascii import hexlify

sinelist = []
newlist = []

for i in range(0, 4096):
    sinelist.append(int(int(0x7FFF) * math.sin(2 * math.pi * i / 4096)))
    
for i in range(0, 4096):
    s = sinelist[i]
    b = s.to_bytes(2, 'big', signed=True)
    h = hexlify(b)
    newlist.append(h)

newnewlist = [str(n)[2:-1] + '\n' for n in newlist]



##f = open("sine.mem", "w")
##
##for n in newnewlist:
##    f.write(n)
##f.writelines(newnewlist)
print(newnewlist)

##plt.plot(sinelist)
##plt.show()

