import ptufile as pt
import numpy as np

class read_ptu():
    def read_return_ptu(self, file):

        ptu = pt.PtuFile(file)

        dims = ptu.dims
        t_axis = dims.index('T') if 'T' in dims else None

        aux = ptu.decode_image(asxarray=True)
        if hasattr(ptu, 'number_bins_in_period'):
            aux = aux[:,:,:,:,:ptu.number_bins_in_period]
                    
        aux = np.asarray(aux, dtype=np.float32)           

        if t_axis is not None:
            aux = np.sum(aux, axis=t_axis)

        

        return aux
    
d = read_ptu()
e = d.read_return_ptu(file)