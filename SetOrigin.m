%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                                                                                     %%%
%%%   SetOrigin function                                                                                                                %%%
%%%                                                                                                                                     %%%
%%%   INPUTS:                                                                                                                           %%%
%%%                                                                                                                                     %%%
%%%   socketID: XPS-Q8 ID                                                                                                               %%%
%%%   positioner: set of positioner communication labels                                                                                %%%
%%%   LimMaxZ: height of the floor                                                                                                      %%%
%%%   AskOrigin: Whether the origin of the grid has been set                                                                            %%%
%%%   AskDimension: Wheter the dimension of the grid has been set                                                                       %%%
%%%   AskForbiddenVolume: Whether a Forbidden Volume has been set                                                                       %%%
%%%   ForbiddenVolume: Set of diagonally opposing points that define the upper surface of the rectangular prism of a Forbidden Volume   %%%
%%%   NumberForbiddenVolume: Number of Forbidden Volumes set                                                                            %%%
%%%                                                                                                                                     %%%
%%%   OUTPUTS:                                                                                                                          %%%
%%%                                                                                                                                     %%%
%%%   Origin: position of the origin of the grid in relation to the positioner's 'HOME'                                                 %%%
%%%   AskOrigin: Whether the origin of the grid has been set                                                                            %%%
%%%   AskDimension: Wheter the dimension of the grid has been set                                                                       %%%
%%%   AskForbiddenVolume: Whether a Forbidden Volume has been set                                                                       %%%
%%%   ForbiddenVolume: Set of diagonally opposing points that define the upper surface of the rectangular prism of a Forbidden Volume   %%%
%%%   NumberForbiddenVolume: Number of Forbidden Volumes set                                                                            %%%
%%%                                                                                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Origin,AskOrigin,AskDimension,AskForbiddenVolume,ForbiddenVolume,NumberForbiddenVolume] = SetOrigin(socketID,positioner,LimMaxZ,AskOrigin,AskDimension,AskForbiddenVolume,ForbiddenVolume,NumberForbiddenVolume)

    i = 1;
    if AskOrigin == 1   %If Origin is already set and wants to be changed
        [indx,tf] = listdlg('ListString',{'Yes','No'},'SelectionMode','single','Name','CAUTION! Changing the origin requires resetting the dimension of the grid and the forbidden volumes!. Are you sure you want to change the origin?','ListSize',[700,50],'InitialValue',2);
        if indx == 1    %Reset all the other parameters
            AskOrigin = 0;  %Reset Askorigin so that the program executes the next 'if'
            AskDimension = 0;
            AskForbiddenVolume = 0;
            ForbiddenVolume = [];
            NumberForbiddenVolume = 0;
        end
    end
    if AskOrigin == 0
        [Return] = MoveArmManually(socketID,positioner,1,i,LimMaxZ);    %Function to manually move the probe to the Origin
        if Return == 0  
            %Save the coordinates of the Origin
            [Error, Origin(1)] = GroupPositionCurrentGet (socketID, positioner{2},1);
            [Error, Origin(2)] = GroupPositionCurrentGet (socketID, positioner{1},1);
            [Error, Origin(3)] = GroupPositionCurrentGet (socketID, positioner{3},1);

            AskOrigin = 1;
        else   %if process cancelled, not save the Origin
            Origin = [];
        end
    end
end