function [] = muntaCSV2(varargin)
% muntaCSV2(file,separator,variables)
% Creates file.csv using separator character.
% will attempt to use writematrix and switch to muntaCSV if fail
% muntaCSV2 is faster for large data sets but slower for small

try
    rut=varargin{1};
    sep=varargin{2};
    ext=rut(end-2:end);
    N=nargin;
    cops=0;
    for ii=3:N
        cops=cops+1;
        var=varargin{ii};
        if(ischar(var)),var={var};end
        aux=class(var);        
        switch aux(1:3)
            case 'cel'
                if(strcmp(ext,'xls'))
                    if(cops>1)
                        writecell(var,rut,'WriteMode','append');
                    else
                        writecell(var,rut);
                    end
                else
                    if(cops>1)
                        writecell(var,rut,'Delimiter',sep,'WriteMode','append');
                    else
                        writecell(var,rut,'Delimiter',sep);
                    end
                end
            case {'dou','uin'}
                if(strcmp(ext,'xls'))
                    if(cops>1)
                        writematrix(var,rut,'WriteMode','append');
                    else
                        writematrix(var,rut);
                    end
                else
                    if(cops>1)
                        writematrix(var,rut,'Delimiter',sep,'WriteMode','append');
                    else
                        writematrix(var,rut,'Delimiter',sep);
                    end
                end
        end
    end

catch
    % disp('fail')
    if(strcmp(ext,'xls'))
        rut=[rut(1:end-3) 'csv'];
    end
    fra='';
    for ii=3:N
        eval(['A' num2str(ii) '=varargin{ii};']);
        fra=[fra 'A' num2str(ii) ','];
    end
    fra(end)=[];
    eval(['muntaCSV(rut,sep,' fra ');']);
end