function [name,folder] = uisaveFile(titol,type,filename)
% get folder path for saving and remember last path
% returns strings
%
if(nargin<2),type='*.mat';end
if(nargin<1),titol=' ';end
fname=['F' dec2hex(sum(double(titol)))];
if(nargin<2),N=9999;end
if(isempty(titol)),titol='Save as';end
folder='';
ruta='lastsavefolder.mat';
try% attempt to save user settings file in matlab folder
        rut=[userpath];
        if(exist(rut,'dir')~=7)
            mkdir(rut);
        end
        ruta=[rut filesep 'lastsavefolder.mat'];    
end
try 
    load(ruta);
    eval(['folder=' fname ';']);
end
if(nargin>2),folder=[folder filesep filename];end
    [name,folder]=uiputfile(type,titol,folder);
        
        eval([fname '=''' folder ''';']);
        try
       eval(['save(''' ruta ''',''' fname ''',''-append'');']);
        catch
            eval(['save(''' ruta ''',''' fname ''');']);
        end
   

end