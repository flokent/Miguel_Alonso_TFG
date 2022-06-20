%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                                                                                     %%%
%%%   SetLimits function                                                                                                                %%%
%%%                                                                                                                                     %%%
%%%   OUTPUTS:                                                                                                                          %%%
%%%                                                                                                                                     %%%
%%%   Limits: lateral limits of the scanning volume                                                                                     %%%
%%%                                                                                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Limits] = SetLimits

    Ready = 0;

    while Ready == 0
        %user inputs the values of the limmits
        description = {'Limits x (mm):','Limits y (mm):','Limits z (mm):'};
        title = 'Set the boundaries to the outtermost faces of the forbidden volume';
        Limits = inputdlg(description,title,[1 90;1 90;1 90]);
        
        %check that the inputs are valid
        if size(Limits) == [0 0]
            Ready = 1;
            Limits = [];
        else
            for i = 1:3
                Answer = str2num(Limits{i});
                if isempty(Answer) == 1
                    [~,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The inputs are not valid. Click continue','ListSize',[500,50]);
                    Limits = [];
                    Ready = 0;
                    break
                elseif Answer>=0
                    Ready = 1;
                else
                    [~,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The inputs can not be negative numbers. Click continue','ListSize',[500,50]);
                    Ready = 0;
                    break
                end
            end
        end
    end
end