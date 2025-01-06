function [M] = niceNums(N,opt,ex)
% express number N with opt singificative figures. 
%If for the case of numbers lower than the figures, an exponential format
%is required set ex=1 (default ex=0)
if(nargin<3),ex=0;end
if(isnan(N))
    M='0';
else
if(nargin==1)
    if(abs(N)<.01)
        opt=ceil(log10(abs(N)));
    else
    opt=2;
    end
end

if(N==0)
   M='0';
   if(opt>0)
       M='0.';
   for ii=1:opt
       M=[M '0'];
   end
   end
else

M=num2str(N);
e=strfind(lower(M),'e');

if(~isempty(e))&&(ex==1)
    
    xp=M(e+1:end);
    M=M(1:e-1);
    
else
  M=num2str(round(N*10^opt)/10^opt);  
end

MM=M;
p=strfind(M,'.');
if(~isempty(p))
    if(opt==0)
        M=num2str(round(str2num(M)));
    end
    
    if(opt>0)
        M=M(1:p);
        
        decimals=num2str(round((10^opt)*str2num(['0.' MM(p+1:end)])));
        if(length(decimals)<opt)
            for ii=1:opt-length(decimals)
                decimals=['0' decimals];
            end
        end
        if(length(decimals)>opt)
            M=num2str(str2num(M)+(str2num(decimals)/(10^opt)));
        else
            M=[M decimals];
        end
    end
    
    
end

p=strfind(M,'.');
if((isempty(p))&&(opt>0))
    M=[M '.'];
    for ii=1:opt
        M=[M '0'];
    end
end

if(~isempty(e))&&(ex==1)
    M=[M 'e' xp];
end

if(ex==1)
kk=M;kk(kk=='.')=[];
if((length(unique(kk))==1)&&(kk(1)=='0'))
    M=niceNums(N/1000000,2,1);
    xp=num2str(str2num(M(end-1:end))-6);
    if(length(xp)==1),xp=['0' xp];end
    M(end-1:end)=xp;
end
end
end
end
end
