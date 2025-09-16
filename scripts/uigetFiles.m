function [filepaths] = uigetFiles(titol,N,multi,filterspec)
% get N file paths selected individualy and remember last path
% returns cell of N paths (or a string if N==1). 
% if N is not specified it keeps asking until cancelled
% multi is a flag for multiselection in each iteration
if(nargin<4),filterspec='*.*';end
if((nargin<3)||(multi==0))||isempty(multi),selmode='off';else selmode='on';end
if(nargin<1),titol=' ';end
fname=['F' dec2hex(sum(double(titol)))];
if(nargin<2),N=9999;end
if(isempty(titol)),titol='Select file(s)';end
aux=1;filepath='';

ruta='lastfile.mat';
try% attempt to save user settings file in matlab folder
    if(~isempty(getenv('USERPROFILE')))% windows machine
        rut=[getenv('USERPROFILE') filesep 'Documents' filesep 'MATLAB'];
        if(exist(rut,'dir')~=7)
            mkdir(rut);
        end
        ruta=[rut filesep 'lastfile.mat'];
    end
    if(~isempty(getenv('HOME')))% mac machine
        rut=[getenv('HOME') filesep 'Documents' filesep 'MATLAB'];
        if(exist(rut,'dir')~=7)
            mkdir(rut);
        end
        ruta=[rut filesep 'lastfile.mat'];
    end
end
try 
    load(ruta);
    eval(['filepath=' fname ';']);
end
Nn=0;Nm=0;filepaths=cell(0);
while(aux==1)
    
    [file,folder]=uigetfile(filterspec,titol,filepath, 'MultiSelect', selmode);



    if(strcmp(class(folder),'double')==0)
        if(strcmp(class(file),'cell'))
            Nn=Nn+1;Nm=0;
         for ii=1:numel(file)
        Nm=Nm+1;
        filepath=[folder file{ii}];
        filepaths{end+1}=filepath;
         end
        else
        Nn=Nn+1;
        filepath=[folder file];
        filepaths{Nn}=filepath;
        end
        eval([fname '=''' filepath ''';']);
        if(exist(ruta,'file')==0)
eval(['save(''' ruta ''',''' fname ''');']);
        else
       eval(['save(''' ruta ''',''' fname ''',''-append'');']);
        end
    else
        break;
    end
    if(Nn==N),break;end
end
if(Nn==1)&&(Nm==0),filepaths=filepaths{1};end
end