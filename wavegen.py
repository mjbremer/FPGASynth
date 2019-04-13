import math
import matplotlib.pyplot as plt
from binascii import hexlify
from sys import argv

if (len(argv) != 3):
    print("Usage: wavegen.py <sine/square/saw/triangle> <number of harmonics>")
    exit()


listlen = 4096
waveshape = argv[1]
nharm = int(argv[2])
A = int(0x7FFF)

coefs = []

if (waveshape == "sine"):
    coefs = [A] + [0 for n in range(nharm - 1)]
    # print(coefs)
elif (waveshape == "saw"):
    coefs = [((1.8*A/math.pi) * ((-1)**k) / k) for k in range(1,nharm+1)]
    ## Typically this is supposed to be a 2, but due to the Gibbs Phenomenom the peak amplitude
    ## Runs past 0x7FFF, so we have to nerf it a little bit to fit in within 2 signed bytes
elif (waveshape == "square"):
    # This is also supposed to be 4. Yeah these got nerfed a lot lol
    coefs = [((k%2) * A * (3.3/math.pi) / k) for k in range(0, nharm)]
    # print(coefs)
elif (waveshape == "triangle"):
    coefs = []
    for i in range(1, nharm+1):
        if (i%2==0):
            coefs.append(0)
        else:
            coefs.append((((-1)**((i-1)/2)) * A * (8/(math.pi**2)) / (i**2)) )
    ##print(coefs)

wavelist = []
for i in range(0, listlen):
    sample = 0
    for k in range(0, nharm):
        sample += coefs[k] * math.sin(2 * math.pi * i * (k+1) / listlen)
    wavelist.append(int(sample))
    

textlist = []
## Generate text version of the hex
for i in range(0, len(wavelist)):
    s = wavelist[i]
    # print(s)
    b = s.to_bytes(2, 'big', signed=True)
    h = hexlify(b)
    textlist.append(h)


## Format the list to be readable by quartus and write it to file
filelist = [str(n)[2:-1] + '\n' for n in textlist]
f = open(waveshape + "test.mem", "w")
f.writelines(filelist)

##print(filelist)
# plt.plot(wavelist)
# plt.show()

