function [SS,GG] = phasorSmooth(SS,GG,eb,ti,ga,im,fill)
% eb is size of medfilt2 matrix (3 in simFCS, 5 for Xtreme)
% ti is number of times it is to be applied
% ga is a flag in order to do median(0), mean(1) or gaussian(2) filtering.
% if ga=1 and an image is given of the same size as SS and GG, the mean is weighted by im
%    defaulted to 0
% fill=1 attempts to substitute NaNs by mean of surrounding values (defaulted to 0 )
%    
if(nargin<7)||isempty(fill),fill=0;end
if(nargin<5)||isempty(ga),ga=0;end
if(fill==1) 
    [SS] = phasorFillNaN2(SS,[eb,ti]);
    [GG] = phasorFillNaN2(GG,[eb,ti]);
end


switch ga
    case 0
        vec=[eb,eb];
    case 1
        filtre=ones(eb,eb)/eb/eb;
    case 2
        filtre=fspecial('gaussian',eb,ti);
end
if(ga==0)
    for jj=1:size(SS,3)
        for ii=1:ti
            SS(:,:,jj)=medfilt2(SS(:,:,jj),vec);
            GG(:,:,jj)=medfilt2(GG(:,:,jj),vec);
        end
    end
end
if(ga==1)
    if(nargin>=6)
        ref=im;
        
        
            SS=SS.*im;
            GG=GG.*im;
            ref=conv2(ref,filtre,'same');
        
    end
    for jj=1:size(SS,3)
        for ii=1:ti
            
            SS(:,:,jj)=conv2(SS(:,:,jj),filtre,'same');
            GG(:,:,jj)=conv2(GG(:,:,jj),filtre,'same');
        end
    end
    if(nargin>=6)
        SS=SS./ref;
        GG=GG./ref;
        if(ti>1)
           ti=ti-1;
           [SS,GG] = phasorSmooth(SS,GG,eb,ti,ga,im);
        end
    end
    
end
if(ga==2)
    for jj=1:size(SS,3)
        for ii=1:ti
            SS(:,:,jj)=conv2(SS(:,:,jj),filtre,'same');
            GG(:,:,jj)=conv2(GG(:,:,jj),filtre,'same');
        end
    end
end
end