function [I3] = balance3Chan(I3,rg)
% thirds dimension is channels, stacks should be in 4th
 TT=[3 4 6 6]/3;% obtained after the calibration modification
                DD=TT*0;
                sz=get(0,'screensize');
% since images are going to be seeen on a screen we have to integrate over
% groups of pixels (taken from manipulateIms.m)
factor=sz(3)/size(I3,1);% )
vb=.01;% lower
vt=.005;%upper
if(nargin>1)
vb=rg(1);vt=1-rg(2);factor=1;
end

                   if(size(I3,4)==1)
                    aux=imresize(I3,factor);
                   else
                       aux=I3;
                   end
                    % cap value
                    q=quantile(aux(:),1-vt/factor/factor);
                    TT=TT*q;
                    
                    % get dark level
                    for cc=1:size(I3,3)
                        imC=I3(:,:,cc,:);
                        DD(1,cc)=quantile(imC(:),vb/factor/factor);                        
                    end
                    for cc=1:size(I3,3)
                        aux=I3(:,:,cc,:);
                        % aux=aux/TT(kk);
                        aux=(aux-DD(1,cc))/(TT(1,cc)-DD(1,cc));
                        aux(aux>1)=1;aux(aux<0)=0;
                        I3(:,:,cc,:)=aux;                        
                                              
                    end   

                    if(size(I3,3)>3)% achtung, 4 chan image
% T=I3(:,:,4);
aux3=sum(sum(I3(:,:,3,:),2),1);
aux4=sum(sum(I3(:,:,4,:),2),1);
% we split what used to go to B into B and T so we need to enhance both
I3(:,:,3)=I3(:,:,3,:)*.5*(aux3+aux4)/aux3;% one half bc we are doubling at the top (TT(3,4)=2)
I3(:,:,4)=I3(:,:,4,:)*.5*(aux3+aux4)/aux4;% one half bc we are doubling at the top (TT(3,4)=2)

%%% aux=I3(:,:,1:3);aux(:,:,3)=aux(:,:,3)+I3(:,:,4);figure,imagesc(aux);
col=[0 1 1];
I3=I3(:,:,1:3,:)+gray3rgb(I3(:,:,4,:),col);
% I3=I3(:,:,1:3);

                    end
                

end