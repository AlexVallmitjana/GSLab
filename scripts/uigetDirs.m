function [folders] = uigetDirs(titol,N)
% get N folder paths and remember last path
% returns cell of N paths (or a string if N==1).
% if N is not specified it keeps asking until cancelled
%
if(nargin<1),titol=' ';end
fname=['F' dec2hex(sum(double(titol)))];
if(nargin<2),N=9999;end
if(isempty(titol)),titol='Select mother folder(s)';end
aux=1;folder='';
ruta='lastfolder.mat';
try% attempt to save user settings file in matlab folder
    if(~isempty(getenv('USERPROFILE')))% windows machine
        rut=[getenv('USERPROFILE') filesep 'Documents' filesep 'MATLAB'];
        if(exist(rut,'dir')~=7)
            mkdir(rut);
        end
        ruta=[rut filesep 'lastfolder.mat'];
    end
    if(~isempty(getenv('HOME')))% mac machine
        rut=[getenv('HOME') filesep 'Documents' filesep 'MATLAB'];
        if(exist(rut,'dir')~=7)
            mkdir(rut);
        end
        ruta=[rut filesep 'lastfolder.mat'];
    end
end
try
    load(ruta);
    eval(['folder=' fname ';']);
end
Nn=0;folders=cell(0);
while(aux==1)
    folder=uigetdir(folder,titol);
    if(strcmp(class(folder),'double')==0)
        Nn=Nn+1;
        folders{Nn}=folder;
        try
            folder=folder(1:find(folder==filesep,1,'last'));
        end
        eval([fname '=''' folder ''';']);
        try
            eval(['save(''' ruta ''',''' fname ''',''-append'');']);
        catch
            eval(['save(''' ruta ''',''' fname ''');']);
        end
    else
        break;
    end
    if(Nn==N),break;end
end
if(Nn==1),folders=folders{1};end
end