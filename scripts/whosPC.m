function [qui,id] = whosPC(qui)

if(nargin==0)
qui=getenv('COMPUTERNAME');
end
id=0;
switch qui
    case 'ALEX_PC'
        qui='Alex';id=1;
    case 'AFDURKIN-2020'
        qui='Amanda';id=1;
    case 'LAPTOP-4SS4H9HR'
        qui='Belen';id=1;
    case 'SUMAN-BLI'
        qui='Suman';id=1;
    case 'DESKTOP-I0A9SVE'
        qui='FLAME3';id=1;
    case 'MBF'
        qui='FLAME2';id=1;
    otherwise
end

end