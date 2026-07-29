import ptufile as pt
import numpy as np

class read_ptu():
    def read_return_ptu(self, file):
        #print("Start")
        ptu = pt.PtuFile(file)
        

        #print("Shape:", ptu.shape)
        #print("Dimension:", ptu.dims)
        #print(ptu)
        dims = ptu.dims
        
        #print("Before Decoding")

        t_axis = dims.index('T') if 'T' in dims else None
        if t_axis is not None:
            aux = ptu.decode_image(frame=-1, asxarray=True)
        else:
            aux = ptu.decode_image(asxarray=True)

        aux = np.asarray(aux, dtype=np.float32)
        #aux = np.squeeze(aux, axis=0)        (512, 512, 2, 2509)

        #print("Decoded")
        if hasattr(ptu, 'number_bins_in_period'):
            aux = aux[:,:,:,:,:ptu.number_bins_in_period]
        #print("yes")            
        
        aux = np.ascontiguousarray(aux)

        return aux
    
d = read_ptu()
e = d.read_return_ptu(file)