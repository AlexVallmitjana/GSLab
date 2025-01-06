function [type,centre] = definetype(nom)
            centre=[0 0];
            switch nom
                case 'S'
                    type=3;%linear
                    centre=[0 -1000];% x,y
                case 'G'
                    type=3;%linear
                    centre=[-1000 0];% x,y
                case 'Phase'
                    type=1;%angular
                    centre=[0 0];% x,y
                case 'Mod'
                    type=2;%radial
                      centre=[0 0];
                case 'TauPhase'
                    type=1;%angular
                    centre=[0 0];% x,y
                case 'TauMod'
                    type=2;%radial
                      centre=[0 0];
                case 'NormPhase'
                     type=1;%angular
                     centre=[.5 0];% x,y
                case 'TauNorm'
                    type=1;%angular
                    centre=[.5 0];% x,y
                case 'CustomRadial'
                    type=2;%angular
                    centre=[ ];% x,y
                case 'CustomAngular'
                    type=1;%angular
                    centre=[ ];% x,y
            end

end