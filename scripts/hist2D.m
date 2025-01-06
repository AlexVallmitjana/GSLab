function [I,tk1,tk2,inds] = hist2D(v1,v2,bins,rangs)
% primer X despres Y
% tk are tick position (row1) and value (row2)
if(length(v1)~=length(v2)),error('Vectors must be same length.');end
if(nargin<3)
bins=[100,100];
end
if(nargin<4)
    rangs=[min(v1),max(v1);min(v2),max(v2)];
end
e1=linspace(rangs(1,1),rangs(1,2),bins(1));
e2=linspace(rangs(2,1),rangs(2,2),bins(2));
%[e1(1),e1(end);e2(1),e2(end)]

I=zeros(bins(2),bins(1));

ord=[1:length(v1)]';
out=unique([find(v1>e1(end));find(v2>e2(end));find(isnan(v1));find(isnan(v2));find(v1<e1(1));find(v2<e2(1))]);
v1(out)=[];v2(out)=[];ord(out)=[];

inds=zeros(length(v1),2);

for ii=1:length(v1)
   i2=find(e1>=v1(ii),1,'first')-1; 
   i1=find(e2>=v2(ii),1,'first')-1; 
   if(i1==0),i1=1;end;if(i2==0),i2=1;end
   I(bins(2)+1-i1,i2)=I(bins(2)+1-i1,i2)+1;
   
    inds(ii,1:2)=[bins(2)+1-i1,i2];
end
inds(:,3)=ord;

tk=niceTicks([e1(1) e1(end)]);tk1=[tk;tk];
for ii=1:length(tk)
       i2=find(e1>=tk(ii),1,'first');tk1(1,ii)=i2;
end
tk=niceTicks([e2(1) e2(end)]);tk2=[tk;tk];
for ii=1:length(tk)
       i2=find(e2>=tk(ii),1,'first');tk2(1,ii)=bins(2)+1-i2;
end
tk2=tk2(:,end:-1:1);
end