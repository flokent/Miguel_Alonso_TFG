%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                                                                                     %%%
%%%   DeleteForbiddenVolume function                                                                                                    %%%
%%%                                                                                                                                     %%%
%%%   INPUTS:                                                                                                                           %%%
%%%                                                                                                                                     %%%
%%%   LimMaxZ: height of the floor                                                                                                      %%%
%%%   ForbiddenVolume: Set of diagonally opposing points that define the upper surface of the rectangular prism of a Forbidden Volume   %%%
%%%   NumberForbiddenVolume: Number of Forbidden Volumes set                                                                            %%%
%%%                                                                                                                                     %%%
%%%   OUTPUTS:                                                                                                                          %%%
%%%                                                                                                                                     %%%
%%%   ForbiddenVolume: Set of diagonally opposing points that define the upper surface of the rectangular prism of a Forbidden Volume   %%%
%%%   NumberForbiddenVolume: Number of Forbidden Volumes set                                                                            %%%
%%%                                                                                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ForbiddenVolume, NumberForbiddenVolume] = DeleteForbiddenVolume(ForbiddenVolume,LimMaxZ,NumberForbiddenVolume)

        %Determine parameters to plot the Forbidden Volumes
        figure('Name','Choose Forbidden Volume','Position',[100 100 1700 800])
        Options(1,:) = ['Delete all Forbidden Volumes    '];
        %Axis limmits
        AxisLimitXmin = min(ForbiddenVolume(1,1,:),[],3);
        AxisLimitXmax = max(ForbiddenVolume(1,2,:),[],3);
        AxisLimitYmin = min(ForbiddenVolume(2,1,:),[],3);
        AxisLimitYmax = max(ForbiddenVolume(2,2,:),[],3);
        AxisLimitZ = min(ForbiddenVolume(3,1,:),[],3);
        %Plots per row
        if mod(NumberForbiddenVolume,2) == 0
            PlotsPerRow = NumberForbiddenVolume;
        else
            PlotsPerRow = NumberForbiddenVolume + 1;
        end
        
        for i = 1:NumberForbiddenVolume
            if i<=ceil(NumberForbiddenVolume/2)
                PositionCentralPlot(i) = ceil(NumberForbiddenVolume/2)+i;
            else
                if mod(NumberForbiddenVolume,2) == 0
                    PositionCentralPlot(i) = NumberForbiddenVolume+i;
                else
                    if NumberForbiddenVolume == 1
                        PositionCentralPlot(i) = 2;
                    else
                        PositionCentralPlot(i) = NumberForbiddenVolume+i+1;
                        if i == NumberForbiddenVolume
                            PositionCentralPlot(i+1) = NumberForbiddenVolume+i+2;
                        end
                    end
                end
            end
        end
        
        %Plot all the Forbidden Volumes individualy and together with different colors
        for i = 1:NumberForbiddenVolume
            Options(i+1,:) = ['Delete Forbidden Volume number ' num2str(i)];
            
            XFace = [ForbiddenVolume(1,1,i) ForbiddenVolume(1,2,i) ForbiddenVolume(1,2,i) ForbiddenVolume(1,1,i) ForbiddenVolume(1,1,i)];
            YFace = [ForbiddenVolume(2,1,i) ForbiddenVolume(2,1,i) ForbiddenVolume(2,2,i) ForbiddenVolume(2,2,i) ForbiddenVolume(2,1,i)];
            ZUpperFace = [LimMaxZ-ForbiddenVolume(3,1,i); LimMaxZ-ForbiddenVolume(3,1,i); LimMaxZ-ForbiddenVolume(3,1,i); LimMaxZ-ForbiddenVolume(3,1,i); LimMaxZ-ForbiddenVolume(3,1,i)];
            ZBottomFace = [0;0;0;0;0];
            
            if mod(i,3) == 1
                if i<=ceil(NumberForbiddenVolume/2)
                    PositionPlot = i;
                else
                    if NumberForbiddenVolume == 1
                        PositionPlot = NumberForbiddenVolume;
                    else
                        PositionPlot = NumberForbiddenVolume + i-floor(NumberForbiddenVolume/2);
                    end
                end
                surf(subplot(2,PlotsPerRow,PositionPlot),[XFace;XFace].', [YFace;YFace].', [ZBottomFace,ZUpperFace],'FaceColor','red','FaceAlpha',.3)
                hold(subplot(2,PlotsPerRow,PositionPlot),'on')
                patch([XFace;XFace].', [YFace;YFace].', [ZBottomFace,ZBottomFace],'red','FaceAlpha',.3)                   % Color red
                patch([XFace;XFace].', [YFace;YFace].', [ZUpperFace,ZUpperFace],'red','FaceAlpha',.3)                     % Color red
                hold(subplot(2,PlotsPerRow,PositionPlot),'on')
                text((ForbiddenVolume(1,2,i)-ForbiddenVolume(1,1,i))/2+ForbiddenVolume(1,1,i),(ForbiddenVolume(2,2,i)-ForbiddenVolume(2,1,i))/2+ForbiddenVolume(2,1,i),(LimMaxZ-ForbiddenVolume(3,1,i))/2,num2str(i),'Color','red','FontSize',30)
                axis equal
                axis([AxisLimitXmin-10 AxisLimitXmax+10 AxisLimitYmin-10 AxisLimitYmax+10 0 LimMaxZ-AxisLimitZ])
                hold(subplot(2,PlotsPerRow,PositionPlot),'off')
                
                surf(subplot(2,PlotsPerRow,PositionCentralPlot),[XFace;XFace].', [YFace;YFace].', [ZBottomFace,ZUpperFace],'FaceColor','red')
                hold(subplot(2,PlotsPerRow,PositionCentralPlot),'on')
                patch([XFace;XFace].', [YFace;YFace].', [ZBottomFace,ZBottomFace],'red')                   % Color red
                patch([XFace;XFace].', [YFace;YFace].', [ZUpperFace,ZUpperFace],'red')                     % Color red
                axis equal
                axis([AxisLimitXmin-10 AxisLimitXmax+10 AxisLimitYmin-10 AxisLimitYmax+10 0 LimMaxZ-AxisLimitZ])
                hold(subplot(2,PlotsPerRow,PositionCentralPlot),'on')
            elseif mod(i,3) == 2
                if i<=ceil(NumberForbiddenVolume/2)
                    PositionPlot = i;
                else
                    if NumberForbiddenVolume == 1
                        PositionPlot = NumberForbiddenVolume;
                    else
                        PositionPlot = NumberForbiddenVolume + i-floor(NumberForbiddenVolume/2);
                    end
                end
                surf(subplot(2,PlotsPerRow,PositionPlot),[XFace;XFace].', [YFace;YFace].', [ZBottomFace,ZUpperFace],'FaceColor','magenta','FaceAlpha',.3)
                hold(subplot(2,PlotsPerRow,PositionPlot),'on')
                patch([XFace;XFace].', [YFace;YFace].', [ZBottomFace,ZBottomFace],'magenta','FaceAlpha',.3)                   % Color magenta
                patch([XFace;XFace].', [YFace;YFace].', [ZUpperFace,ZUpperFace],'magenta','FaceAlpha',.3)                     % Color magenta
                hold(subplot(2,PlotsPerRow,PositionPlot),'on')
                text((ForbiddenVolume(1,2,i)-ForbiddenVolume(1,1,i))/2+ForbiddenVolume(1,1,i),(ForbiddenVolume(2,2,i)-ForbiddenVolume(2,1,i))/2+ForbiddenVolume(2,1,i),(LimMaxZ-ForbiddenVolume(3,1,i))/2,num2str(i),'Color','magenta','FontSize',30)
                axis equal
                axis([AxisLimitXmin-10 AxisLimitXmax+10 AxisLimitYmin-10 AxisLimitYmax+10 0 LimMaxZ-AxisLimitZ])
                hold (subplot(2,PlotsPerRow,PositionPlot),'off')
                
                surf(subplot(2,PlotsPerRow,PositionCentralPlot),[XFace;XFace].', [YFace;YFace].', [ZBottomFace,ZUpperFace],'FaceColor','magenta')
                hold(subplot(2,PlotsPerRow,PositionCentralPlot),'on')
                patch([XFace;XFace].', [YFace;YFace].', [ZBottomFace,ZBottomFace],'magenta')                   % Color magenta
                patch([XFace;XFace].', [YFace;YFace].', [ZUpperFace,ZUpperFace],'magenta')                     % Color magenta
                axis equal
                axis([AxisLimitXmin-10 AxisLimitXmax+10 AxisLimitYmin-10 AxisLimitYmax+10 0 LimMaxZ-AxisLimitZ])
                hold(subplot(2,PlotsPerRow,PositionCentralPlot),'on')
            elseif mod(i,3) == 0
                if i<=ceil(NumberForbiddenVolume/2)
                    PositionPlot = i;
                else
                    if NumberForbiddenVolume == 1
                        PositionPlot = NumberForbiddenVolume;
                    else
                        PositionPlot = NumberForbiddenVolume + i-floor(NumberForbiddenVolume/2);
                    end
                end
                surf(subplot(2,PlotsPerRow,PositionPlot),[XFace;XFace].', [YFace;YFace].', [ZBottomFace,ZUpperFace],'FaceColor','blue','FaceAlpha',.3)
                hold(subplot(2,PlotsPerRow,PositionPlot),'on')
                patch([XFace;XFace].', [YFace;YFace].', [ZBottomFace,ZBottomFace],'blue','FaceAlpha',.3)                   % Color blue
                patch([XFace;XFace].', [YFace;YFace].', [ZUpperFace,ZUpperFace],'blue','FaceAlpha',.3)                     % Color blue
                hold(subplot(2,PlotsPerRow,PositionPlot),'on')
                text((ForbiddenVolume(1,2,i)-ForbiddenVolume(1,1,i))/2+ForbiddenVolume(1,1,i),(ForbiddenVolume(2,2,i)-ForbiddenVolume(2,1,i))/2+ForbiddenVolume(2,1,i),(LimMaxZ-ForbiddenVolume(3,1,i))/2,num2str(i),'Color','blue','FontSize',30)
                axis equal
                axis([AxisLimitXmin-10 AxisLimitXmax+10 AxisLimitYmin-10 AxisLimitYmax+10 0 LimMaxZ-AxisLimitZ])
                hold(subplot(2,PlotsPerRow,PositionPlot),'off')
                
                surf(subplot(2,PlotsPerRow,PositionCentralPlot),[XFace;XFace].', [YFace;YFace].', [ZBottomFace,ZUpperFace],'FaceColor','blue')
                hold(subplot(2,PlotsPerRow,PositionCentralPlot),'on')
                patch([XFace;XFace].', [YFace;YFace].', [ZBottomFace,ZBottomFace],'blue')                   % Color magenta
                patch([XFace;XFace].', [YFace;YFace].', [ZUpperFace,ZUpperFace],'blue')                     % Color magenta
                axis equal
                axis([AxisLimitXmin-10 AxisLimitXmax+10 AxisLimitYmin-10 AxisLimitYmax+10 0 LimMaxZ-AxisLimitZ])
                hold(subplot(2,PlotsPerRow,PositionCentralPlot),'on')
            end
        end
        %Selection menu
        [OptionChosen,tf] = listdlg('ListString',Options,'SelectionMode','single','Name','Choose the forbidden volume to delete','ListSize',[300,100]);
        
        if tf == 1  %if a Forbidden Volume(s) has/have been chosen
            if OptionChosen == 1    %if 'Delete all'
                NumberForbiddenVolume = 0;
                ForbiddenVolume = [];
            else   %if delete only one Forbidden Volume
                NumberForbiddenVolume = NumberForbiddenVolume-1;
                ForbiddenVolume(:,:,OptionChosen-1) = [];
            end
        end
        %Close plots
        close
end