%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                                                                                     %%%
%%%   MoveArmManually function                                                                                                          %%%
%%%                                                                                                                                     %%%
%%%   INPUTS:                                                                                                                           %%%
%%%                                                                                                                                     %%%
%%%   socketID: XPS-Q8 ID                                                                                                               %%%
%%%   positioner: set of positioner communication labels                                                                                %%%
%%%   LimMaxZ: height of the floor                                                                                                      %%%
%%%   OptionChosen: determines whether the call to the function is to determine the Origin, the Floor or a Forbidden Volume             %%%
%%%                                                                                                                                     %%%
%%%   OUTPUTS:                                                                                                                          %%%
%%%                                                                                                                                     %%%
%%%   Return: determines whether the execution of the function has finalized succesfully or the user has cancelled                      %%%
%%%                                                                                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Return] = MoveArmManually(socketID,positioner,OptionChosen,i,LimMaxZ)
    %Parameter initialization
    Ready = 2;
    errorCode = 0;
    Answer = {'',''};
    Return = 0;
    while Ready == 2    %While the user has not confirmed or cancelled
        
        if OptionChosen == 1    %Menu when setting the origin
            text = {'Movement (in mm):','Select Axis (x/y/z) or safe point (s) or if you want to return to the main menu (r):'};
            title = 'Choose the axis and movement to determine the origin';
            Answer = inputdlg(text,title,[1 100;1 100],{'',Answer{2}});
        elseif OptionChosen == 2    %Menu when setting the floor
            text = {'Movement (in mm):','Select Axis (x/y/z) or safe point (s) or if you want to return to the main menu (r):'};
            title = 'Choose the axis and movement to determine the floor';
            Answer = inputdlg(text,title,[1 100;1 100],{'',Answer{2}});
        elseif OptionChosen == 3    %Menu when setting a Forbidden Volume
            if i == 1   %When it is the first point
                text = {'Movement (in mm):','Select Axis (x/y/z) or safe point (s) or if you want to return to the main menu (r):'};
                title = 'Choose the axis and movement to determine the forbidden volume upper corner point ';
                Answer = inputdlg(text,[title num2str(i)],[1 120;1 120],{'',Answer{2}});
            else   %When it is the second point
                text = {'Movement (in mm):','Select Axis (x/y) or safe point (s) or if you want to return to the main menu (r):'}; %no te dice que puedas poner la z
                title = 'Choose the axis and movement to determine the forbidden volume opposite upper corner point ';
                Answer = inputdlg(text,[title num2str(i)],[1 120;1 120],{'',Answer{2}});
            end
        end
        
        if isempty(Answer) == 0 %if user has not cancelled
            Movement = str2num(Answer{1});  %convert to num. if Answer{1} is not a number, it leaves Movement empty
            if ((isempty(Movement) == 1 && isempty(Answer{1}) == 0)||(isempty(Movement) == 1 && any(ismember({'x','y','z'},Answer{2}))))      %if the inputs are not in the correct forn
                Answer = {'',''};   %Empty Answer so that an error pops up later
            end
        elseif size(Answer) == [0 0]  %if Answer is a 0x0 the user has cancelled
            Answer{2} = 'r';    %'r' indicates return to menu
        end
        
        if isequal(Answer{2} ,'x')
            [errorCode] = GroupMoveRelative(socketID, positioner{2}, Movement); %Move in X direction
        elseif isequal(Answer{2} ,'y')
            [errorCode] = GroupMoveRelative(socketID, positioner{1}, Movement); %Move in Y direction
        elseif isequal(Answer{2} ,'z')
            if i == 1
                
                [errorCode, CurrentPositionZ] = GroupPositionCurrentGet (socketID, positioner{3},1);    %get current position of probe
                if (CurrentPositionZ + Movement > LimMaxZ && OptionChosen ~= 2) %check that moving the arm in Z axis does not collide with the floor
                    [indx,tf] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','Atention! Movement is not possible as it would hit the floor. Click continue','ListSize',[700,50]);
                else
                [errorCode] = GroupMoveRelative(socketID, positioner{3}, Movement); %if save to move, move in Z direction
                end
            else %if trying to change the height of the second point when determining a forbidden volume, which is not allowed
                [indx,tf] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The height has already been set by the first point. Click continue','ListSize',[500,50]);
            end
        elseif isequal(Answer{2} ,'s')  %if point is readdy and user wants to save
            Ready = 1;
        elseif isequal(Answer{2} ,'r')  %if user wants to cancel
            %check if user is sure
            [Ready,tf] = listdlg('ListString',{'Yes','No'},'SelectionMode','single','Name','Are you sure you want to exit to the selection menu?','ListSize',[500,50],'InitialValue',2);
            if tf == 0
                Ready = 2;
            end
            if Ready == 1
                Return = 1;
            end
            Answer = {'',''};   %in case user does ultimately does not want to cancel, Answer is set to empty so that the displacement selection menu does not pop up with a preset 'r'
        else %if the inputs are not valid
            [indx,tf] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The input is not recognized. Make sure to type in x,y,z (and a number) or s or r. Click continue','ListSize',[700,50]);
            Answer = {'',''};
        end
        
        if errorCode == -17     %erro that occurs if the movement displacement the user has selected is ut of bounds
            [indx,tf] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The value selected is out of bounds. Click continue','ListSize',[500,50]);
            errorCode = 0;
        end
        
    end
end