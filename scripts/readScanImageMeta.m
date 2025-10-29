function [dad] = readScanImageMeta(ruta)

G=fopen(ruta,'rt');
cont=(fread(G,inf,'uchar'))';% l
fclose(G);
% fields to fish out
interest={"tileSizeUm","tileResolution","tileCornerPtsUm","tileZs","framesPerTile","channelsSaved","bidirectionalCorrection"};
valors=cell(size(interest));
fields=find(cont==34);% quotes
N=numel(fields);
fields=[fields numel(cont)];
cc=0;
for ii=1:2:numel(fields)-1
    camp=char(cont(fields(ii)+1:fields(ii+1)-1));
    for jj=1:numel(interest)
        if(strcmp(camp,interest{jj}))
            valor=cont(fields(ii+1)+2:fields(ii+2)-1);
            final=find(valor==44,1,'last')-1;% comma
            if(ii==numel(fields)-2)% last one has no comma
                final=find(valor==125,1,'first')-1;% end curly
            end
            % char(valor)
            valor=valor(1:final);
            valor(valor==10)=[];%remove end of line
            valor(valor==13)=[];%remove end of line in mac
            valor(valor==32)=[];%remove spaces
            cc=cc+1;
            valors{jj}=char(valor);
        end
    end
end
% if(cc~=jj),ensenya('Warning: Not all fields were there','a');end
fra='dad=struct(';
for ii=1:length(valors)
    if(isempty(valors{ii}))
        if(strcmp(interest{ii},"bidirectionalCorrection"))
            valors{ii}='0';
        else
            valors{ii}='[]';
        end
    end
    fra=[fra '"' char(interest{ii}) '"' ',' valors{ii} ','];
end
fra(end)=')';
fra=[fra ';'];
eval(fra);

end