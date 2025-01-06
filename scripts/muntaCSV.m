function [] = muntaCSV(varargin)
% muntaCSV(file,separator,variables)
% Creates file.csv using separator character.


sep=varargin{2};
N=nargin;

L=0;
A=0;
for ii=3:N
[a,b]=size(varargin{ii});
L=L+a;
A=A+b;
end

c=0;
parrafada=cell(L,1);

for ii=3:N
   c=c+1;parrafada{c}=sep;  
 var=varargin{ii};
  
 if(ischar(var)),
   c=c+1;parrafada{c}=var;
 else
 if(iscell(var)),
 [a,b]=size(var);

 for jj=1:a
      frase='';
   for kk=1:b  
       v1=var{jj,kk};
%       if(b>1)%ischar(v1)),
          if(ischar(v1)==0),v1=num2str(v1);end
       frase=[frase v1 sep];
       %c=c+1;parrafada{c}=frase; 
%       else
%            if(iscell(v1)),error('Sorry no cell of cells allowed yet.');end
%        [a1,b1]=size(v1);
%     for j1=1:a1
%         frase='';
%        for k1=1:b1
%        
%        valor=num2str(v1(j1,k1));
%     frase=[frase valor sep];
%        end
%        %c=c+1;parrafada{c}=frase; 
%     end
%       end
   end
    c=c+1;parrafada{c}=frase;  
 end
 else
   [a,b]=size(var);
 for jj=1:a
     frase='';
   for kk=1:b  
       valor=num2str(var(jj,kk));
    frase=[frase valor sep];
   end
     c=c+1;parrafada{c}=frase;  
 end   
 end
end
end
rutadades=[varargin{1}];
if(length(rutadades)>256),rutadades=[rutadades(1:252) '.csv'];end
pumpum=fopen(rutadades,'wt');
for ii=1:length(parrafada)
   
    fprintf(pumpum,'%s\n',parrafada{ii}); 
    
end
fclose(pumpum);




end
