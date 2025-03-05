function [IT2] = stitchMosaic(IT,m,n)
dfx=0;% cut this much from each juntion in X
dfy=0;% cut this much from each juntion in Y
dfxr=0;% add this X at the begining after each row
dfyr=0;% add this Y at the begining after each col
zigzag=1;% if files are sorted not in the saving order for bidirectional tiling
if(m*n>1)
N=size(IT,4);
if(zigzag==0)
    ordre=[1:N];
else
    ordre=[];
    for kk=1:m
        if(mod(kk,2)==1),ordre=[ordre,[1+((kk-1)*n):((kk)*n)]];end
        if(mod(kk,2)==0),ordre=[ordre,[((kk)*n):-1:1+((kk-1)*n)]];end
    end
end
% ordre(ordre>size(IT,4))=[];
cc=0;% tile counter
ro=0;% row counter
[a,b,c,d]=size(IT);
IT2=zeros(m*a+dfyr*(m-1)-a*(2*m-2),n*b+dfxr*(n-1)-b*(2*n-2),c);
% If=zeros(a,n*b,c);
ensenya('Stitching     ');
bcut=b-dfx*2;
acut=a-dfy*2;
% ordre=[1:25];
% ordre=[1 2 3 4 5 10 9 8 7 6 11 12 13 14 15 20 19 18 17 16 21 22 23 24 25];
for kk=ordre
    cc=cc+1;
   row=ceil(cc/n)-1;% starts at 0
   col=mod(cc-1,n);% starts at 0

    aux=IT(:,:,:,kk);
        
    xrange=[dfx+1,b-dfx];
    % if(col==0),xrange(1)=1;end
    % if(col==n),xrange(2)=b;end
    
    yrange=[dfy+1,a-dfy];
    % if(row==0),yrange(1)=1;end
    % if(row==m),yrange(2)=a;end

    aux=aux(yrange(1):yrange(2),xrange(1):xrange(2),:);
    if(dfxr>=0)
   ex=row*dfxr;
   else
   ex=-(m-row-1)*dfxr;
   end   
   if(dfyr>=0)
   ey=col*dfyr;
   else
   ey=-(n-col-1)*dfyr;
   end
   IT2(ey+row*acut+1:ey+(row+1)*acut,ex+col*bcut+1:ex+(col+1)*bcut,:)=aux;
   
   % if(mod(cc,n)==1),If=aux;else,If=cat(2,If,aux);end
      % if(mod(cc,n)==0)
    %     ro=ro+1;
    %     % if(dfxr>=0)
    %     %     If=cat(2,zeros(size(If,1),dfxr*(m-ro),size(If,3)),If);
    %     %     If=cat(2,If,zeros(size(If,1),dfxr*(ro-1),size(If,3)));
    %     % 
    %     % else
    %     %     If=cat(2,zeros(size(If,1),-dfxr*(ro-1),size(If,3)),If);
    %     %     If=cat(2,If,zeros(size(If,1),-dfxr*(m-ro),size(If,3)));
    %     % end
    %     IT2=cat(1,IT2(1:end-dfy,:,:),If(dfy+1:end,:,:));
    % end    
    percentatge(cc,N);
end  


clear If;
clear aux;
else
    IT2=IT;
end
end