function [type,centre,codi] = definetype(nom)
            centre=[0 0];
            codi=-1;% codi es per la funcio magnitude.m
            switch nom
                case 'S'
                    type=3;%linear
                    centre=[0 -1000];% x,y
                     codi=1;
                case 'G'
                    type=3;%linear
                    centre=[-1000 0];% x,y
                    codi=0;
                case 'Phase'
                    type=1;%angular
                    centre=[0 0];% x,y
                    codi=2;
                case 'Mod'
                    type=2;%radial
                      centre=[0 0];
                      codi=3;
                case 'TauPhase'
                    type=1;%angular
                    centre=[0 0];% x,y
                    codi=5;
                case 'TauMod'
                    type=2;%radial
                      centre=[0 0];
                      codi=6;
                case 'NormPhase'
                     type=1;%angular
                     centre=[.5 0];% x,y
                     codi=4;
                case 'TauNorm'
                    type=1;%angular
                    centre=[.5 0];% x,y
                    codi=7;
                case 'CustomRadial'
                    type=2;%angular
                    centre=[ ];% x,y
                case 'CustomAngular'
                    type=1;%angular
                    centre=[ ];% x,y
            end

end