function [SS,GG,remove,II] = phasorSmoothCrop(SS,GG,eb,ti,II)

 remove=floor(eb/2)*(ti);
            SS=SS(remove+1:end-remove,remove+1:end-remove,:,:);
            GG=GG(remove+1:end-remove,remove+1:end-remove,:,:);
            if(nargin>4)
II=II(remove+1:end-remove,remove+1:end-remove,:,:);
            end

end