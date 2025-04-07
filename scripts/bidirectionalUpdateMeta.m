function [] = bidirectionalUpdateMeta(ruta,shift)


filestxt=dir([ruta filesep '*.txt']);
for ii=1:numel(filestxt)
    pumpum=fopen([ruta filesep filestxt(ii).name],'rt');
    cont=(fread(pumpum,inf,'uchar'))';% l
    fclose(pumpum);
    % check file was not updated
    gg0=findstr(cont,double('bidirectionalCorrection'));
    if(isempty(gg0))% not there, we gotta add
        % find end of last line but one
        gg=findstr(cont,double('],'));
        gg=gg(end)+1;
        % compose new z info
        newsegm=['      "bidirectionalCorrection": ' num2str(shift) ','];
        % insert new line
        newcont=[char([cont(1:gg) 10]) newsegm char(cont(gg+1:end))];
    else% is there, we gotta replace
        gg1=strfind(cont,double(':'));
        gg2=strfind(cont,double(','));
        gg1=gg1(gg1>gg0);gg1=gg1(1);
        gg2=gg2(gg2>gg0);gg2=gg2(1);
        newcont=[char([cont(1:gg1) 32]) num2str(shift) char(cont(gg2:end))];
    end
    %overwrite txt file having updated info
    pumpum=fopen([ruta filesep filestxt(ii).name],'wt');
    fwrite(pumpum,newcont);
    fclose(pumpum);
end
ensenya(['Updated metadata:' ruta],'e');

end
