%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                                                                                     %%%
%%%   MeasureMagneticField function                                                                                                     %%%
%%%                                                                                                                                     %%%
%%%   INPUTS:                                                                                                                           %%%
%%%                                                                                                                                     %%%
%%%   f71: f71 ID                                                                                                                       %%%
%%%   socketID: XPS-Q8 ID                                                                                                               %%%
%%%   positioner: set of positioner communication labels                                                                                %%%
%%%   LimMaxZ: height of the floor                                                                                                      %%%
%%%   Limits: lateral limits of the scanning volume                                                                                     %%%
%%%   NumberSamples: number of samples per point                                                                                        %%%
%%%   Interval: step intervals for each axis                                                                                            %%%
%%%   ForbiddenVolume: Set of diagonally opposing points that define the upper surface of the rectangular prism of a Forbidden Volume   %%%
%%%   NumberForbiddenVolume: Number of Forbidden Volumes set                                                                            %%%
%%%                                                                                                                                     %%%
%%%   OUTPUTS:                                                                                                                          %%%
%%%                                                                                                                                     %%%
%%%   Path: matrix of position points of the probe throughout the scan                                                                  %%%
%%%   Mean: nx4 matrix 3D Magnetic field at each point (B,Bx,By,Bz)                                                                     %%%
%%%                                                                                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Path,Mean] = MeasureMagneticField(f71,socketID,positioner,ForbiddenVolume,Limits,NumberSamples,NumberForbiddenVolume,Interval,LimMaxZ)
    %INITIALIZE PARAMETERS
    
    %Direction of movement along X or Y axis. 1 if along positive
    %direction, -1 if along negative direction
    directionX = 1;
    directionY = 1;
    
    %Minimum and maximum positions along X and Y axis of the scanning volume
    LimMinX = min(ForbiddenVolume(1,1,:))-str2num(Limits{1});
    LimMaxX = max(ForbiddenVolume(1,2,:))+str2num(Limits{1});
    LimMinY = min(ForbiddenVolume(2,1,:))-str2num(Limits{2});
    LimMaxY = max(ForbiddenVolume(2,2,:))+str2num(Limits{2});


    LimMinZ = min(ForbiddenVolume(3,1,:))-str2num(Limits{3});   %height of the tallest Forbidden Volume
    %LimMaxZ is given
    PassedForbiddenVolume = 0;
    
    %'FirstMove' Determines whether the computed position is the first one in the X/Y/Z axis
    FirstMoveX = 0;
    FirstMoveY = 0;
    FirstMoveZ = 0;
    
    %'NextPosition' is used to determine the next position of the probe, in
    %order to check whether said position is within a Forbidden Volume
    %before moving the probe
    NextPositionX = LimMinX;
    NextPositionY = LimMinY;
    NextPositionZ = LimMinZ;
    RealNextPosition = [NextPositionX-LimMinX,NextPositionY-LimMinY,LimMaxZ - NextPositionZ];
    
    %'CrossedForbiddenPoint' is used to determine whether a point is within a Forbidden Volume
    CrossedForbiddenPoint = zeros(1,NumberForbiddenVolume);

    k = 1;
    Path(k,:) = RealNextPosition;   %Save the Path


    %Move to initial point
    [errorCode] = GroupMoveAbsolute(socketID, positioner{3}, LimMinZ);
    [errorCode] = GroupMoveAbsolute(socketID, positioner{1}, LimMinY);
    [errorCode] = GroupMoveAbsolute(socketID, positioner{2}, LimMinX);

    Sample = 0;
    
    WhichForbiddenVolume = NumberForbiddenVolume;   %Has to be set to the number of Forbidden Volumes, because they are
                                                    %ordered from tallest to shortest, and it is required later when
                                                    %determining the height of the dodging sequence to keep the height of
                                                    %the tallest even if it crosses various Forbidden Volumes
    %SCANNING SEQUENCE
    for z = LimMinZ:Interval(3):LimMaxZ   %determines number steps along Z axis

        if FirstMoveZ == 0  %if it is the first move in the Z axis, no need to check if it is in a forbidden volume
            FirstMoveZ = 1;
        else
            NextPositionZ = NextPositionZ + Interval(3);    %determine next position along Z axis
            NextPosition = [NextPositionX,NextPositionY,NextPositionZ];
            for n = 1:NumberForbiddenVolume   %check whether the NextPosition is within a Forbidden Volume
                if (NextPosition(1)>=ForbiddenVolume(1,1,n)) && (NextPosition(1)<=ForbiddenVolume(1,2,n)) && (NextPosition(2)>=ForbiddenVolume(2,1,n)) && (NextPosition(2)<=ForbiddenVolume(2,2,n)) && (NextPosition(3)>ForbiddenVolume(3,1,n))
                    %NextPosition is within a ForbiddenVolume
                    CrossedForbiddenPoint(n) = 1;   
                    WhichForbiddenVolume = n;   %Determines the Forbidden Volume that has been crossed.
                   
                    break   %Once a Forbidden Volume has been crossed, as it will be taller than those that will be checked after, it is not needed to keep checking
                            
                end
            end
            if any(CrossedForbiddenPoint) == 1
                break   %if CrossedForbiddenPoint = 1 whilst checking in the Z axis, it can only mean it is a flyover, and thus should stop the sequence when encountering the top surface of the ForbiddenVolume
            else   %if it is not within a Forbidden Volume, move down in the Z axis
                [errorCode] = GroupMoveRelative(socketID, positioner{3}, Interval(3)) ; %move down in the Z axis the amount determined by the Z axis step interval

                RealNextPosition = [NextPositionX-LimMinX, NextPositionY-LimMinY, LimMaxZ - NextPositionZ]                  %Show the Position the probe is moving to
                Path(k,:) = RealNextPosition;       %Save the Path
            end

        end
            for x = LimMinX:Interval(1):LimMaxX  %determines number steps along X axis

                if FirstMoveX == 0  %if it is the first move in the X axis, no need to check if it is in a forbidden volume, because it has already been checked in the previous axis
                    FirstMoveX = 1;
                else
                    NextPositionX = NextPositionX + Interval(1)*directionX; %determine next position along X axis
                    NextPosition = [NextPositionX,NextPositionY,NextPositionZ];                    
                    
                    for n = 1:NumberForbiddenVolume   %to check whether the NextPosition is within a Forbidden Volume
                        if ((NextPosition(1)>ForbiddenVolume(1,1,n)) && (NextPosition(1)<ForbiddenVolume(1,2,n)) && (NextPosition(2)>ForbiddenVolume(2,1,n)) && (NextPosition(2)<ForbiddenVolume(2,2,n)) && (NextPosition(3)>ForbiddenVolume(3,1,n)))...
                                || (((NextPosition(2)+Interval(2)*floor((LimMaxY-LimMinY)/Interval(2)))<ForbiddenVolume(2,2,n) || (NextPosition(2)-Interval(2)*floor((LimMaxY-LimMinY)/Interval(2)))>ForbiddenVolume(2,1,n))&& (NextPosition(1)>ForbiddenVolume(1,1,n)) && (NextPosition(1)<ForbiddenVolume(1,2,n)) && (NextPosition(3)>ForbiddenVolume(3,1,n)))
                            CrossedForbiddenPoint(n) = 1;   %Save that a Forbidden Volume has been crossed
                            if n < WhichForbiddenVolume   %check whether the Forbidden Volume is taller than any Forbidden Volume the probe has previously checked
                                WhichForbiddenVolume = n;   %save only if it is the tallest Forbidden Volume it has crossed
                            end
                            break                       %Once a Forbidden Volume has been crossed, as it will be taller than those that will be checked after, it is not needed to keep checking
                        elseif any(CrossedForbiddenPoint) == 1  %if the point is not in a Forbidden Volume but the previous point was
                            PassedForbiddenVolume = 1;  %the computed point is past the Forbidden Volume
                        end

                    end

                    if any(CrossedForbiddenPoint) == 1      %if a Forbidden Volume is or has been crossed while checking points
                        if PassedForbiddenVolume == 1   %if the Forbidden Volume has passed
                            %DODGING SEQUENCE
                            [errorCode] = GroupMoveAbsolute(socketID, positioner{3}, ForbiddenVolume(3,1,WhichForbiddenVolume)-20);    %move up Z axis
                                        [~, currentPosition] = GroupPositionCurrentGet(socketID, positioner{3}, 1);
                                        currentPosition     %show position probe
                            [errorCode] = GroupMoveAbsolute(socketID, positioner{2}, NextPosition(1));      %move to dodge in X axis
                                        [~, currentPosition] = GroupPositionCurrentGet(socketID, positioner{1}, 1);
                                        currentPosition     %show position probe
                            [errorCode] = GroupMoveAbsolute(socketID, positioner{3}, NextPosition(3)) ;     %move back down Z axis
                                        [~, currentPosition] = GroupPositionCurrentGet(socketID, positioner{3}, 1);
                                        currentPosition     %show position probe
                            CrossedForbiddenPoint(:) = 0;   %reset the parameter
                            PassedForbiddenVolume = 0;      %reset the parameter

                            RealNextPosition = [NextPositionX-LimMinX, NextPositionY-LimMinY, LimMaxZ - NextPositionZ]    %show position probe
                            Path(k,:) = RealNextPosition;       %Save Path

                        else
                            %If the Forbidden Volume has not passed do nothing and check next point
                        end
                    else   %if at no point has a Forbidden Volume been crossed, the checked point is save to move to
                        RealNextPosition = [NextPositionX-LimMinX, NextPositionY-LimMinY, LimMaxZ - NextPositionZ]    %show position probe
                        Path(k,:) = RealNextPosition;       %Save Path
                        [errorCode] = GroupMoveRelative(socketID, positioner{2}, Interval(1)*directionX);   %Move to the position
                    end
                end
                if any(CrossedForbiddenPoint) ~= 1      %if the point is not in a Forbidden Volume, movement in the Y direction can begin 
                    for y = LimMinY:Interval(2):LimMaxY   %determines number steps along Y axis

                        if FirstMoveY == 0                      %if it is the first move in the Y axis, no need to check if it is in a forbidden volume, because it has already been checked in the previous axis
                            FirstMoveY = 1;
                            Sample = 1;
                        else

                            NextPositionY = NextPositionY + Interval(2)*directionY; %determine next position along Y axis
                            NextPosition = [NextPositionX,NextPositionY,NextPositionZ];

                            for n = 1:NumberForbiddenVolume
                                if (NextPosition(1)>ForbiddenVolume(1,1,n)) && (NextPosition(1)<ForbiddenVolume(1,2,n)) && (NextPosition(2)>ForbiddenVolume(2,1,n)) && (NextPosition(2)<ForbiddenVolume(2,2,n)) && (NextPosition(3)>ForbiddenVolume(3,1,n))
                                    CrossedForbiddenPoint(n) = 1;   %Save that a Forbidden Volume has been crossed
                                    if n < WhichForbiddenVolume   %check whether the Forbidden Volume is taller than any Forbidden Volume the probe has previously checked
                                        WhichForbiddenVolume = n;   %save only if it is the tallest Forbidden Volume it has crossed
                                    end
                                    PassedForbiddenVolume = 0; %En caso de que salga de una zona prohibida y acto seguido entre en una nueva zona prohibida
                                    break                       %Once a Forbidden Volume has been crossed, as it will be taller than those that will be checked after, it is not needed to keep checking
                                elseif CrossedForbiddenPoint(n) == 1    %if the point is not in a Forbidden Volume but the previous point was
                                    PassedForbiddenVolume = 1;  %the computed point is past the Forbidden Volume
                                end
                            end

                            if any(CrossedForbiddenPoint) == 1      %if a Forbidden Volume is or has been crossed while checking points
                                if PassedForbiddenVolume == 1   %if the Forbidden Volume has passed
                                    %DODGING SEQUENCE
                                    [~] = GroupMoveAbsolute(socketID, positioner{3}, ForbiddenVolume(3,1,WhichForbiddenVolume)-20);    %move up Z axis
                                                [~, currentPosition] = GroupPositionCurrentGet(socketID, positioner{3}, 1);
                                                currentPosition     %show position probe
                                    [~] = GroupMoveAbsolute(socketID, positioner{1}, NextPosition(2));      %move to dodge in X axis
                                                [~, currentPosition] = GroupPositionCurrentGet(socketID, positioner{1}, 1);
                                                currentPosition     %show position probe
                                    [errorCode] = GroupMoveAbsolute(socketID, positioner{3}, NextPosition(3)) ;     %move back down Z axis
                                                [~, currentPosition] = GroupPositionCurrentGet(socketID, positioner{3}, 1);
                                                currentPosition     %show position probe
                                    CrossedForbiddenPoint(:) = 0;   %reset the parameter
                                    PassedForbiddenVolume = 0;      %reset the parameter
                                    Sample = 1;                     %Determines that the magnetometer has to take a measurement

                                    RealNextPosition = [NextPositionX-LimMinX, NextPositionY-LimMinY, LimMaxZ - NextPositionZ]   %show position probe
                                    Path(k,:) = RealNextPosition;       %Save Path
                                else
                                     %If the Forbidden Volume has not passed do nothing and check next point
                                end
                            else   %if at no point has a Forbidden Volume been crossed, the checked point is save to move to
                                RealNextPosition = [NextPositionX-LimMinX, NextPositionY-LimMinY, LimMaxZ - NextPositionZ]   %show position probe
                                Path(k,:) = RealNextPosition;       %Save Path
                                [errorCode] = GroupMoveRelative(socketID, positioner{1}, Interval(2)*directionY); %Move to the position
                                Sample = 1;                     %Determines that the magnetometer has to take a measurement
                            end
                        end
                        %IN CASE ERROR OF MOTION OF THE POSITIONER
                        if (errorCode ~= 0)
                             disp (['Error ' num2str(errorCode) ' occurred while doing GroupMoveAbsolute ! ']) ;
                             return ;
                        end

                        if Sample == 1  %If the Magnetometer has to take measurements
                            pause(0.2);     %pause to stabilize the probe
                            for i=1:NumberSamples   %Take as many measurements as 'NumberSamples'
                                fprintf(f71, 'FETCh:DC? ALL')   %ask the magnetometer for the data
                                Data(i,:) = str2num(fscanf(f71));   %read the data provided by the teslameter
                            end
                            if NumberSamples == 1
                                Mean(k,:) = Data;   %this has to be done because an error would happen if the number of samples is 1
                            else
                                Mean(k,:) = mean(Data);     %Compute mean of all the measurements at the point
                            end
                            k = k+1;    %change position in the matrix for the next measurements
                            Sample = 0; %reset parameter
                        end



                    end
                    directionY = directionY*(-1);   %Once the probe reaches the limit along Y direction, in order to go back in the opposite direction, the sign is switched
                    FirstMoveY = 0; %reset parameter
                    WhichForbiddenVolume = NumberForbiddenVolume;   %reset parameter
                end

            end

            directionX = directionX*(-1);   %Once the probe reaches the limit along X direction, in order to go back in the opposite direction, the sign is switched
            FirstMoveX = 0; %reset parameter
            WhichForbiddenVolume = NumberForbiddenVolume;   %reset parameter
    end
    
end