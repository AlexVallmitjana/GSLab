function [I3] = gray3rgb(I,c)
% project grayscale NxMx1 image into RGB using color c
if(ischar(c)),c=superjet(1,c);end
if(size(I,3)==1)
    I3=repmat(I,[1 1 3]);
    for cc=1:3
        I3(:,:,cc)=I3(:,:,cc)*c(cc);
    end
else
    I3=repmat(I,[1 1 1 3]);
    for cc=1:3
        I3(:,:,:,cc)=I3(:,:,:,cc)*c(cc);
    end
end
end