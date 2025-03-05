import sdtfile as sd
import numpy as np
#import matplotlib.pyplot as plt

class read_sdt():
    def read_return_sdt(self, file):
        sdt = sd.SdtFile(file)
        #print(np.array(sdt.data)[0,:,:,0].shape)
        return np.array(sdt.data)

d = read_sdt()
e = d.read_return_sdt(file)
#plt.imshow(e)
#plt.show()