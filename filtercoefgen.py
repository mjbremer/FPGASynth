import math
import matplotlib.pyplot as plt
from binascii import hexlify

sinelist = []
newlist = []

for i in range(0, 2**7):
    sinelist.append(int(int(0xFFFFFF) * (440. * 2.**((i-69)/12) / 48000.)))
    
for i in range(0, 2**7):
    s = sinelist[i]
    b = s.to_bytes(3, 'big', signed=False)
    print(b)
    h = hexlify(b)
    newlist.append(h)

newnewlist = [str(n)[2:-1] for n in newlist]


for n in newnewlist:
    print(n)
##plt.plot(sinelist)
##plt.show()

