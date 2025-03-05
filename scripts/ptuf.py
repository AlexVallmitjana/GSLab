import ptufile as pt
import numpy as np
#import matplotlib.pyplot as plt

class read_sdt():
    def read_return_ptu(self, file):
        ptu = pt.PtuFile(file)
        #print(ptu.dims)
        #print(ptu.shape)
        #print(ptu.active_channels)
        #print(ptu.decode_histogram(dtype='uint8'))
        return np.array(ptu.decode_image(channel=0, asxarray=True))
        #return 3
        

d = read_sdt()
e = d.read_return_ptu(file)
#plt.imshow(e)
#plt.show()