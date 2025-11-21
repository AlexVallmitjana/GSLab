function [] = requiredFilesGenerate()

S=dir('C:\Users\austi\Documents\GitHub\GSLab\scripts\*.*');
cc=0;
cc=cc+1;parrafada{cc}='function [filelist] = requiredFiles()';
cc=cc+1;parrafada{cc}='cc=0;filelist=cell(0);';
cc=cc+1;parrafada{cc}='cc=cc+1;filelist{cc}=''GSLab.mlapp'';';
for ii=3:numel(S)
    cc=cc+1;parrafada{cc}=['cc=cc+1;filelist{cc}=''scripts/' S(ii).name ''';'];
end
cc=cc+1;parrafada{cc}='filelist=filelist'';';
cc=cc+1;parrafada{cc}='end';

gg=which('requiredFiles.m');

pumpum=fopen(gg,'wt');
for ii=1:length(parrafada)
    fprintf(pumpum,'%s\n',parrafada{ii}); 
end
fclose(pumpum);


end