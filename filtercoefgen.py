import math
import matplotlib.pyplot as plt
from binascii import hexlify


def f(x):
    return int((2**13) * x)


def g(x):
    return ["0x" + str(hexlify(i.to_bytes(2, 'big', signed=True)))[2:-1] for i in x]

sinelist = []
newlist = []

filtermode = 1
Q = 1

wlist = [(2. * math.pi * 440. * 2.**((i-69)/12) / 48000.) for i in range(0, 2**7)]

sinelist = [math.sin(w) for w in wlist]
coslist  = [math.cos(w) for w in wlist]

alphalist = [sin / (2*Q) for sin in sinelist]

a0list = [1/(1 + alpha) for alpha in alphalist]
a1list = [-1*(-2 * cos) for cos in coslist]
a2list = [-1*(1 - alpha) for alpha in alphalist]

b0list = [ 2**1 * (1-cos)/2 for cos in coslist]
b1list = [2**1 * 1-cos for cos in coslist]
b2list = [2**1 * (1-cos)/2 for cos in coslist]




a0list = list(map(f, a0list))
a1list = list(map(f, a1list))
a2list = list(map(f, a2list))
b0list = list(map(f, b0list))
b1list = list(map(f, b1list))
b2list = list(map(f, b2list))
# for i in range(0, 2**7):
#     sinelist.append(int(int(2**13) * (440. * 2.**((i-69)/12) / 48000.)))
    
# for i in range(0, 2**7):
#     s = a0list[i]
#     b = s.to_bytes(2, 'big', signed=True)
#     #print(b)
#     h = hexlify(b)
#     newlist.append(h)

# # newnewlist = ["0x" + str(n)[2:-1] for n in newlist]


a0list = g(a0list)
a1list = g(a1list)
a2list = g(a2list)
b0list = g(b0list)
b1list = g(b1list)
b2list = g(b2list)


print("int16_t lpf_table [][] = {")
for i in range(len(a0list)):
    print("{{{},{},{},{},{},{}}},".format(a0list[i], a1list[i], a2list[i], b0list[i], b1list[i], b2list[i]))

# for n in newnewlist:
#     print(n)
##plt.plot(sinelist)
##plt.show()


