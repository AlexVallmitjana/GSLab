function [PPx,alp] = white2alpha(PPx,fac,cut,phsz)
% Generate alpha channel from RGB image 
% fac is the sensitivity to white (1 for max, lower for less)
% cut =1 will remove unnecessary white edges
% phsz is output size can be specified by phsz
if(nargin<2),fac=1;end
  if(max(PPx(:))>1)  
top=765*fac;
  else
top=3*fac;
  end
  [a,b]=find(sum(PPx,3)<top);
  if(nargin>3)&&(cut==1)
    PPx=PPx(min(a):max(a),min(b):max(b),:);
  end
    if(nargin>3)
    PPx=imresize(PPx,phsz);
    end
    alp=ones(size(PPx,1),size(PPx,2));
    a=find(sum(PPx,3)>=top);
    alp(a)=0;

end