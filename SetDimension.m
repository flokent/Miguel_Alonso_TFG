%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                                                                                     %%%
%%%   SetDimension function                                                                                                             %%%
%%%                                                                                                                                     %%%
%%%   INPUTS:                                                                                                                           %%%
%%%                                                                                                                                     %%%
%%%   socketID: XPS-Q8 ID                                                                                                               %%%
%%%   positioner: set of positioner communication labels                                                                                %%%
%%%   Origin: Origin of the grid                                                                                                        %%%
%%%                                                                                                                                     %%%
%%%   OUTPUTS:                                                                                                                          %%%
%%%                                                                                                                                     %%%
%%%   Dimension: X Y Dimensions of the grid                                                                                             %%%
%%%                                                                                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Dimension] = SetDimension(socketID,positioner,Origin)

    Ready = 0;
    
    while Ready == 0
        %set dimensions of grid
        description = {'Set dimension of x (mm):','Set dimension of y (mm):'};
        title = 'Set the dimensions of the grid';
        Dimensionstring = inputdlg(description,title,[1 60;1 60]);
        
        if size(Dimensionstring) == [0 0]  %if Answerstring is a 0x0 cell the user has cancelled
            Ready = 1;
            Dimension = [];
            Problem = 1;
        else
            %check inputs are valid
            for i = 1:2
                Answer = str2num(Dimensionstring{i});
                if isempty(Answer) == 1
                    [Problem,tf] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The inputs are not valid. Click continue','ListSize',[500,50]);
                    if tf == 0
                        Problem = 1;
                    end
                    Dimension = [];
                    break
                else
                    if Answer <=0
                        [Problem,tf] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The inputs must be positive numbers. Click continue','ListSize',[500,50]);
                        if tf == 0
                            Problem = 1;
                        end
                        Ready = 0;
                        break
                    else
                        %if inputs are valid save
                        Dimension(i) = Answer;
                        Problem = 0;
                    end
                end
            end
        end
        
        if Problem == 0
            %move probe to expected opposite corner to origin of the grid
            [errorCode] = GroupMoveRelative(socketID, positioner{3}, -150); 
            [errorCode] = GroupMoveRelative(socketID, positioner{2}, Dimension(1));
            [errorCode] = GroupMoveRelative(socketID, positioner{1}, Dimension(2));
            [errorCode] = GroupMoveAbsolute(socketID, positioner{3}, Origin(3));
            %ask whether the point is correct
            [Problem,tf] = listdlg('ListString',{'Yes','No'},'SelectionMode','single','Name','Is this the correct point?','ListSize',[700,50]);
            if tf == 0
                Problem = 2;
            elseif (tf == 1 && Problem ==1)
                Problem = 0;
            end
        end
        if Problem == 2 %if point is not correct, go back to origin and repeat process
            [errorCode] = GroupMoveRelative(socketID, positioner{3}, -150); 
            [errorCode] = GroupMoveRelative(socketID, positioner{2}, -Dimension(1));
            [errorCode] = GroupMoveRelative(socketID, positioner{1}, -Dimension(2));
            [errorCode] = GroupMoveAbsolute(socketID, positioner{3}, Origin(3));
        elseif Problem == 0 %if origin correct, save
            Ready = 1;
        end
    end
end