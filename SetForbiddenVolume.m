%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                                                                                     %%%
%%%   SetForbiddenVolume function                                                                                                       %%%
%%%                                                                                                                                     %%%
%%%   INPUTS:                                                                                                                           %%%
%%%                                                                                                                                     %%%
%%%   Option: 1 if physical grid method, 2 if non physical grid method                                                                  %%%
%%%   socketID: XPS-Q8 ID                                                                                                               %%%
%%%   positioner: set of positioner communication labels                                                                                %%%
%%%   LimMaxZ: height of the floor                                                                                                      %%%
%%%   OptionChosen: =3 to determine it is to set a FrobiddenVolume                                                                      %%%
%%%   NumberForbiddenVolume: Number of Forbidden Volumes set                                                                            %%%
%%%   ForbiddenVolume: Set of diagonally opposing points that define the upper surface of the rectangular prism of a Forbidden Volume   %%%
%%%   Origin: Origin of the grid                                                                                                        %%%
%%%   Dimension: X Y Dimensions of the grid                                                                                             %%%
%%%   AskForbiddenVolume: Whether a Forbidden Volume has been set                                                                       %%%
%%%                                                                                                                                     %%%
%%%   OUTPUTS:                                                                                                                          %%%
%%%                                                                                                                                     %%%
%%%   NumberForbiddenVolume: Number of Forbidden Volumes set                                                                            %%%
%%%   AskForbiddenVolume: Whether a Forbidden Volume has been set                                                                       %%%
%%%   ForbiddenVolume: Set of diagonally opposing points that define the upper surface of the rectangular prism of a Forbidden Volume   %%%
%%%                                                                                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [NumberForbiddenVolume,AskForbiddenVolume,ForbiddenVolume] = SetForbiddenVolume(Option,socketID,positioner,LimMaxZ,OptionChosen,NumberForbiddenVolume,ForbiddenVolume,Origin,Dimension,AskForbiddenVolume)
    
    if Option == 2
        Ready = 0;
        indx = 0;
        while Ready == 0    %if physical grid method
            %User input of the coordinates of the sample
            text = {'Lower Coordinate X1 (mm):','Upper Coordinate X2 (mm):','Lower Coordinate Y1 (mm):','Upper Coordinate Y2 (mm):','Height (mm):'};
            title = 'Determine the Forbidden Volume';
            Answerstring = inputdlg(text,title,[1 60;1 60;1 60;1 60;1 60]);
            
            %Check whether the inputs are valid
            if size(Answerstring) == [0 0]
                Ready = 1;
                indx = 1;
            else
                for i = 1:5
                    Answer = str2num(Answerstring{i});
                    if isempty(Answer) == 1
                        [indx,tf] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The inputs are not valid. Click continue','ListSize',[500,50]);
                        if tf == 0
                            indx = 1;
                        end
                        break
                    else
                        Coordinates(i) = Answer;
                    end
                end
            end
            
            %check that the Forbidden Volume is within the Dimensions of the grid
            if (indx == 0 && Coordinates(1)<Coordinates(2) && Coordinates(3)<Coordinates(4) && Coordinates(5)>0 && Coordinates(1)>=0 && Coordinates(3)>=0 && Coordinates(2)<=Dimension(1) && Coordinates(4)<=Dimension(2))
                NumberForbiddenVolume = NumberForbiddenVolume + 1;  %account for the new forbidden volume
                ForbiddenVolume(1,1,NumberForbiddenVolume) = Origin(1) + Coordinates(1)-4;      %save the data with margin of error that accounts for the width of the probe
                ForbiddenVolume(2,1,NumberForbiddenVolume) = Origin(2) + Coordinates(3)-4;
                ForbiddenVolume(1,2,NumberForbiddenVolume) = Origin(1) + Coordinates(2)+4;
                ForbiddenVolume(2,2,NumberForbiddenVolume) = Origin(2) + Coordinates(4)+4;
                ForbiddenVolume(3,[1 2],NumberForbiddenVolume) = Origin(3) - Coordinates(5)-2;
                Ready = 1;
                AskForbiddenVolume = 1;
            elseif indx == 0
                [~,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The inputs are not valid to correctly create a forbidden volume. Click continue','ListSize',[600,50]);

            end
            indx = 0;
        end

    elseif Option == 3  %if non physcal grid method
        
        NumberForbiddenVolume = NumberForbiddenVolume + 1; %account for the new forbidden volume
        
        for i = 1:2 %for the two points that define the forbidden volume
            Ready = 0;
            while Ready == 0    %move arm until it is in the desired position
                [Return] = MoveArmManually(socketID,positioner,OptionChosen,i,LimMaxZ);

                [~, ForbiddenVolume(1,i,NumberForbiddenVolume)] = GroupPositionCurrentGet (socketID, positioner{2},1);
                [~, ForbiddenVolume(2,i,NumberForbiddenVolume)] = GroupPositionCurrentGet (socketID, positioner{1},1);
                [~, ForbiddenVolume(3,i,NumberForbiddenVolume)] = GroupPositionCurrentGet (socketID, positioner{3},1);
                if Return == 1 || i == 1
                    Ready = 1;
                else
                    if ForbiddenVolume(1,i,NumberForbiddenVolume) == ForbiddenVolume(1,i-1,NumberForbiddenVolume) || ForbiddenVolume(2,i,NumberForbiddenVolume) == ForbiddenVolume(2,i-1,NumberForbiddenVolume)
                        %checks whether the points are colinear,
                        %which can not define a forbidden volume
                        [~,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The inputs are not valid to correctly create a forbidden volume. Click continue','ListSize',[600,50]);
                    else
                        Ready = 1;
                    end
                end
            end
            if Return == 1
                break
            end
        end
        if Return == 0
            %it does not matter which two opposite points are provided, but
            %when stored, the closest to the origin has to be the first one
            %and the farthest has to be the second one. These lines of code
            %orders the points
            if (ForbiddenVolume(1,1,NumberForbiddenVolume)>ForbiddenVolume(1,2,NumberForbiddenVolume) && ForbiddenVolume(2,1,NumberForbiddenVolume)>ForbiddenVolume(2,2,NumberForbiddenVolume))     %3,2
                ForbiddenVolume(:,[1 2],NumberForbiddenVolume) = ForbiddenVolume(:,[2 1],NumberForbiddenVolume);
            elseif (ForbiddenVolume(1,1,NumberForbiddenVolume)<ForbiddenVolume(1,2,NumberForbiddenVolume) && ForbiddenVolume(2,1,NumberForbiddenVolume)>ForbiddenVolume(2,2,NumberForbiddenVolume))     %1,4
                ForbiddenVolume(2,[1 2],NumberForbiddenVolume) = ForbiddenVolume(2,[2 1],NumberForbiddenVolume);
            elseif (ForbiddenVolume(1,1,NumberForbiddenVolume)>ForbiddenVolume(1,2,NumberForbiddenVolume) && ForbiddenVolume(2,1,NumberForbiddenVolume)<ForbiddenVolume(2,2,NumberForbiddenVolume))     %4,1
                ForbiddenVolume(1,[1 2],NumberForbiddenVolume) = ForbiddenVolume(1,[2 1],NumberForbiddenVolume);
            end
            AskForbiddenVolume = 1;
        else    %if the process is canceled and the first point has already been saved, it has to be deleted
            ForbiddenVolume(:,:,NumberForbiddenVolume) = [];    %delete point
            NumberForbiddenVolume = NumberForbiddenVolume - 1;  %not count the forbidden volume since it has been canceled
            if NumberForbiddenVolume == 0
                AskForbiddenVolume = 0;
            else
                AskForbiddenVolume = 1;
            end
        end
    end
    
    if NumberForbiddenVolume > 1        %ordenarlos de más alto a más bajo, es importante para cuando esquiva los volumenes en caso de que esten solapados
        [~,idx] = sort(ForbiddenVolume,3);
        order = zeros(1,size(ForbiddenVolume,3));
        order(:) = idx(3,1,:);
        ForbiddenVolume = ForbiddenVolume(:,:,order);
    end
    
end