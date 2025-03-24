function [cb] = composeCbar(Crange,nom,sz,cmap,freq)
 skip=0;
switch nom
    case {'S','G','Mod'}
        tv=Crange;
    case {'Phase','NormPhase'}
        tv=Crange*2*3.1416;
    case 'TauPhase'
        taus=[.1 .5 1 2 3 5 8 13 21 34]*1e-9;
        omega=2*3.1416*freq;
        gg=1./(1+(omega*taus).^2);
        ss=(omega*taus)./(1+(omega*taus).^2);
        pseudo=atan2(ss,(gg));
        pseudo(taus==Inf)=3.1416;
        stay=find((pseudo>=Crange(1)*2*3.1416)&(pseudo<=Crange(2)*2*3.1416));
        height=round(256*(pseudo(stay)-Crange(1)*2*3.1416)/((Crange(2)-Crange(1))*2*3.1416));
        tv=cell(0);
        for jj=1:256% taus in cmap locations for tau
            aux=find(height==jj, 1);
            if(~isempty(aux))
                tv{jj}=taus(stay(aux))*1e9;
            else
                tv{jj}=' ';
            end
        end
    case 'TauMod'
        taus=[.1 .5 1 2 3 5 8 13 21 34 Inf]*1e-9;
        omega=2*3.1416*freq;
        gg=1./(1+(omega*taus).^2);
        ss=(omega*taus)./(1+(omega*taus).^2);
        ss(taus==Inf)=0;
        mods=sqrt(gg.*gg+ss.*ss);
        stay=find((mods>=Crange(1))&(mods<=Crange(2)));
        height=round(256*(mods(stay)-Crange(1))/((Crange(2)-Crange(1))));
        height(height==0)=1;
        tv=cell(0);
        for jj=1:256% taus in cmap locations for tau
            aux=find(height==jj, 1);
            if(~isempty(aux))
                tv{jj}=taus(stay(aux))*1e9;
            else
                tv{jj}=' ';
            end
        end

    case 'TauNorm'
        taus=[.1 .5 1 2 3 5 8 13 21 34]*1e-9;
        omega=2*3.1416*freq;
        gg=1./(1+(omega*taus).^2);
        ss=(omega*taus)./(1+(omega*taus).^2);
        pseudo=atan2(ss,(gg-.5));
        pseudo(taus==Inf)=3.1416;
        stay=find((pseudo>=Crange(1)*2*3.1416)&(pseudo<=Crange(2)*2*3.1416));
        height=round(256*(pseudo(stay)-Crange(1)*2*3.1416)/((Crange(2)-Crange(1))*2*3.1416));
        tv=cell(0);
        for jj=1:256% taus in cmap locations for tau
            aux=find(height==jj, 1);
            if(~isempty(aux))
                tv{jj}=taus(stay(aux))*1e9;
            else
                tv{jj}=' ';
            end
        end
    otherwise
        skip=1;
end



%%
if(skip==0)
cb=cbar('sz',[sz round(sz*.09)],'mg',[.03 0],'cm',superjet(cmap),'cv',tv,'fs',round(sz*.028),'fa',.4);
else
cb=[];
end
end

