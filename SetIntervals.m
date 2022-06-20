%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                                                                                     %%%
%%%   SetIntervals function                                                                                                             %%%
%%%                                                                                                                                     %%%
%%%   OUTPUTS:                                                                                                                          %%%
%%%                                                                                                                                     %%%
%%%   Interval: step intervals for each axis                                                                                            %%%
%%%                                                                                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Interval] = SetIntervals
    
    Ready = 0;

    while Ready == 0
        %user input of the intervals
        description = {'Interval x (mm):','Interval y (mm):','Interval z (mm):'};
        title = 'Set the intervals of movement in mm for each axis';
        Intervalstring = inputdlg(description,title,[1 75;1 75;1 75]);

        %check that the inputs are valid
        if size(Intervalstring) == [0 0]
            Ready = 1;
            Interval = [];
        else
            for i = 1:3
                Answer = str2num(Intervalstring{i});
                if isempty(Answer) == 1
                    [~,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The inputs are not valid. Click continue','ListSize',[500,50]);
                    Interval = [];
                    Ready = 0;
                    break
                else
                    if Answer <=0
                        [~,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The inputs must be positive numbers. Click continue','ListSize',[500,50]);
                        Ready = 0;
                        break
                    else
                        Interval(i) = Answer;
                        Ready = 1;
                    end
                end
            end
        end
    end
end