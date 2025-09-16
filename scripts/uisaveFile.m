function [name,folder] = uisaveFile(titol,type)
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
    if(~isempty(getenv('USERPROFILE')))% windows machine
        rut=[getenv('USERPROFILE') filesep 'Documents' filesep 'MATLAB'];
        if(exist(rut,'dir')~=7)
            mkdir(rut);
        end
        ruta=[rut filesep 'lastsavefolder.mat'];
    end
    if(~isempty(getenv('HOME')))% mac machine
        rut=[getenv('HOME') filesep 'Documents' filesep 'MATLAB'];
        if(exist(rut,'dir')~=7)
            mkdir(rut);
        end
        ruta=[rut filesep 'lastsavefolder.mat'];
    end
end
try 
    load(ruta);
    eval(['folder=' fname ';']);
end

    [name,folder]=uiputfile(type,titol,folder);
        
        eval([fname '=''' folder ''';']);
        try
       eval(['save(''' ruta ''',''' fname ''',''-append'');']);
        catch
            eval(['save(''' ruta ''',''' fname ''');']);
        end
   

end