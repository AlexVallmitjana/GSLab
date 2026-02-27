function []= updateGSLab2(pos)


han = waitbar(0,'Downloading','Name','Please wait');
han.Children.Title.Interpreter = 'none';
% han.Position(1)=pos(1);
% han.Position(2)=pos(2);
han.Position(1:3)=pos(1:3);


list=requiredFiles();
ruta='https://alexvallmitjana.github.io/GSLab/';
local=which('GSLab.mlapp');
local=local(1:end-11);

% local='C:\Users\austi\Documents\NewFolder\test\';
cc=0;
ensenya('Downloading..')
for ii=numel(list):-1:1
    cc=cc+1;
    try
        if(strcmp(list{ii},'GSLab.mlapp'))
            delete([local list{ii}]);
        end

        ori=[ruta list{ii}];
        fin=[local list{ii}];
        websave(fin,ori);
        
    catch me
        ensenya(['Error in ' list{ii}]);
        ensenya(me.message);
    end
    han = waitbar(cc/numel(list),han,'Downloading');
end

try,close(han);end


% GSLab;
ensenya('Done!');
ensenya('Please restart GSLab.')

end