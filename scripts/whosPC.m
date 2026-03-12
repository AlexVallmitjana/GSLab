function [qui,id] = whosPC(qui)

if(nargin==0)
    qui=getenv('COMPUTERNAME');
    if(isempty(qui))% mac
        qui=getenv('HOSTNAME');
        if(isempty(qui))
            %[~,qui]=system('HOSTNAME');
            [~, qui] = system('whoami');
            qui = strtrim(qui);
        end
    end
end
id=0;
switch qui
    case 'ALEX_PC'
        qui='Alex';id=420;
    case {'AFDURKIN-2020','AFDURKIN-26'}
        qui='Amanda';id=18;
    case {'LAPTOP-4SS4H9HR','BTORRADO-2025'}
        qui='Belen';id=422;       
    case 'SUMAN-BLI'
        % qui='Suman';id=421;
        qui='Amanda';id=18;
    case 'wz'
        qui='Wenyu';id=1237;
    case 'QWFQFBBQFEBQEFBQEFBQEFB'
        qui='Bruno';id=1238;
    case 'DESKTOP-I0A9SVE'
        qui='FLAME3';id=3;
    case 'MBF'
        qui='FLAME2';id=2;
    case 'DESKTOP-350VFI4'
        qui='Navid';id=1234;
    case {'TYXY','YRYX_COMPUTER'}
        qui='Yryx';id=1235;
    case 'NLOM-BLI'
        qui='NLOMlaptop';id=1236;		
    otherwise
end

end