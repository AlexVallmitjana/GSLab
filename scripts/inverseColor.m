function [col] = inverseColor(col)


gg=0;
if(sum(find(col>1))==0)
   
    col=255*col;
    gg=1;
end


col=255-col;

col=col/255;
    
if(gg==0)
    col=255*col;
end
    
    












end