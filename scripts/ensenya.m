function [] = ensenya(frase,color,addtime)
% display with time stamp and optional color
% addtime is a flag to add time:
%   0 no time (act as disp with color)
%   1 add time
%   2 no time but preceeding spaces for time
frase(frase=='\')='/'; % backslash confuses new versions of matlab
%frase(frase=='%')='*'; % percent confuses interpreter
if(nargin<3),addtime=1;end
if(addtime==0)
    timestamp='';
end
if(addtime==1)
    cl=clock;
    if(cl(4)<10) cl4=['0' num2str(cl(4))];else cl4=num2str(cl(4)); end
    if(cl(5)<10) cl5=['0' num2str(cl(5))];else cl5=num2str(cl(5)); end
    cl6=floor(cl(6));
    if(cl6<10) cl6=['0' num2str(cl6)];else cl6=num2str(cl6); end
    timestamp=[cl4 ':' cl5 ':' cl6 ' '];
end
if(addtime==2)
timestamp=['         '];
end
if(nargin==1)
    disp([timestamp frase]);
else
    if(ischar(color))
        cprintf(superjet(1,color),[timestamp frase '\n']);
    else
        if((size(color,2)==3)&&(size(color,1)==1))
            cprintf(color,[timestamp frase '\n']);
        else
            disp([timestamp frase]);
        end
    end
end

% if(frase(1)~=' ')
% disp([cl4 ':' cl5 ':' cl6 ' ' frase]);
% else
% disp([' ' cl4 ':' cl5 ':' cl6 ' ' frase]);
% end
end