%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                                                                                     %%%
%%%   PlotQuiver function                                                                                                               %%%
%%%                                                                                                                                     %%%
%%%   INPUTS:                                                                                                                           %%%
%%%                                                                                                                                     %%%
%%%   Path: matrix of position points of the probe throughout the scan                                                                  %%%
%%%   Mean: nx4 matrix 3D Magnetic field at each point (B,Bx,By,Bz)                                                                     %%%
%%%   LimMaxZ: height of the floor                                                                                                      %%%
%%%   ForbiddenVolume: Set of diagonally opposing points that define the upper surface of the rectangular prism of a Forbidden Volume   %%%
%%%   Interval: step intervals for each axis                                                                                            %%%
%%%   NumberForbiddenVolume: Number of Forbidden Volumes set                                                                            %%%
%%%   Limits: lateral limits of the scanning volume                                                                                     %%%
%%%   Option2: whether the data is in proportional or logarithmic scale                                                                 %%%
%%%                                                                                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PlotQuiver(Path,Mean,LimMaxZ,ForbiddenVolume,Interval,NumberForbiddenVolume,Limits,Option2)


    LimMinX = min(ForbiddenVolume(1,1,:))-str2num(Limits{1});
    LimMinY = min(ForbiddenVolume(2,1,:))-str2num(Limits{2});
    %call quivercolorsamelength to plot arrows
    quivercolorsamelength(Path(:,1),Path(:,2),Path(:,3),Mean(:,2),Mean(:,3),Mean(:,4),min(Interval),Option2)
    hold on
    %plot the Forbidden Volumes
    for i = 1:NumberForbiddenVolume

        XFace = [ForbiddenVolume(1,1,i) ForbiddenVolume(1,2,i) ForbiddenVolume(1,2,i) ForbiddenVolume(1,1,i) ForbiddenVolume(1,1,i)] - LimMinX;
        YFace = [ForbiddenVolume(2,1,i) ForbiddenVolume(2,1,i) ForbiddenVolume(2,2,i) ForbiddenVolume(2,2,i) ForbiddenVolume(2,1,i)] - LimMinY;
        ZUpperFace = [LimMaxZ-ForbiddenVolume(3,1,i); LimMaxZ-ForbiddenVolume(3,1,i); LimMaxZ-ForbiddenVolume(3,1,i); LimMaxZ-ForbiddenVolume(3,1,i); LimMaxZ-ForbiddenVolume(3,1,i)];
        ZBottomFace = [0;0;0;0;0];
        surf([XFace;XFace].', [YFace;YFace].', [ZUpperFace,ZBottomFace], 'FaceColor','r', 'FaceAlpha',1)
        hold on
        patch([XFace;XFace].', [YFace;YFace].', [ZBottomFace,ZBottomFace],'r', 'FaceAlpha',1)                   % Color Red
        patch([XFace;XFace].', [YFace;YFace].', [ZUpperFace,ZUpperFace],'r', 'FaceAlpha',1)                     % Color red
        hold on

    end
end