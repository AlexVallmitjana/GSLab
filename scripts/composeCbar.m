function [cb] = composeCbar(Crange,nom,sz,cmap,freq,taus)
 skip=0;
switch nom
    case {'S','G','Mod'}
        tv=Crange;
    case {'Phase','NormPhase'}
        tv=Crange*2*3.1416;
    case 'TauPhase'
        taus=taus*1e-9;
        omega=2*3.1416*freq;
        gg=1./(1+(omega*taus).^2);
        ss=(omega*taus)./(1+(omega*taus).^2);
        pseudo=atan2(ss,(gg));
        pseudo(taus==Inf)=3.1416;
        Crange=Crange*2*3.1416;
        Crange=round(1e4*Crange)*1e-4;% round to 4 sigfig
        pseudo=round(1e4*pseudo)*1e-4;% round to 4 sigfig
        stay=find((pseudo>=Crange(1))&(pseudo<=Crange(2)));
        height=1+round(255*(pseudo(stay)-Crange(1))/((Crange(2)-Crange(1))));
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
        taus=taus*1e-9;
        omega=2*3.1416*freq;
        gg=1./(1+(omega*taus).^2);
        ss=(omega*taus)./(1+(omega*taus).^2);
        ss(taus==Inf)=0;
        mods=round(1e4*sqrt(gg.*gg+ss.*ss))*1e-4;% round to 4 sigfig
        Crange=round(1e4*Crange)*1e-4;% round to 4 sigfig
        stay=find((mods>=Crange(1))&(mods<=Crange(2)));
        height=1+round(255*(mods(stay)-Crange(1))/((Crange(2)-Crange(1))));
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
        if(1)% flip cbar
            % Crange=Crange(end:-1:1);
            cmap=cmap(end:-1:1);
            tv=tv(end:-1:1);
        end

    case 'TauNorm'
        taus=taus*1e-9;
        omega=2*3.1416*freq;
        gg=1./(1+(omega*taus).^2);
        ss=(omega*taus)./(1+(omega*taus).^2);
        pseudo=atan2(ss,(gg-.5));
        pseudo(taus==Inf)=3.1416;
        Crange=Crange*2*3.1416;
        Crange=round(1e4*Crange)*1e-4;% round to 4 sigfig
        pseudo=round(1e4*pseudo)*1e-4;% round to 4 sigfig        
        stay=find((pseudo>=Crange(1))&(pseudo<=Crange(2)));
        height=1+round(255*(pseudo(stay)-Crange(1))/(Crange(2)-Crange(1)));
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

