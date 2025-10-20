function [IT] = fishTiffs(folder,verb)
warning('off')
if(nargin<2),verb=1;end
% check if path is to one file
if(strcmp(folder(end-3:end),'.tif'))
    gg=imfinfo(folder);
    N=numel(gg);
    IT=zeros(gg(1).Height,gg(1).Width,N);
    for cc=1:N
        I=imread(folder,cc);

        IT(:,:,cc)=I;
    end
else
    S=dir([folder filesep '*.tif']);
    if(isempty(S))&&strcmp(folder(end-2:end),'tif')% maybe path is to 1 tif file
        aux=find(folder==filesep,1,'last');
        S(1).folder=folder(1:aux-1);
        S(1).name=folder(aux+1:end);
    end
    IT=[];
    if(~isempty(S))
        M=numel(S);
        N=0;
        for ii=1:M
            aux=imfinfo([S(ii).folder filesep S(ii).name]);
            N=max(N,numel(aux));
        end

        IT=zeros(aux(1).Height,aux(1).Width,N,numel(S));

        if(verb==1)
            ensenya('Loading     ');
        end
        for ii=1:M
            for cc=1:N
                try
                    I=imread([S(ii).folder filesep S(ii).name],cc);
                    IT(:,:,cc,ii)=I;
                catch me
                    fprintf('\n');
                    ensenya(me.message,'r');
                    ensenya('Loading     ');
                end
                if(verb==1)
                    percentatge((ii-1)*N+cc,M*N);
                end
            end
            % percentatge(ii,M);
        end


    end
end
end