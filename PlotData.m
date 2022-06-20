%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                                                                                     %%%
%%%   PlotData function                                                                                                                 %%%
%%%                                                                                                                                     %%%
%%%   INPUTS:                                                                                                                           %%%
%%%                                                                                                                                     %%%
%%%   Path: matrix of position points of the probe throughout the scan                                                                  %%%
%%%   Mean: nx4 matrix 3D Magnetic field at each point (B,Bx,By,Bz)                                                                     %%%
%%%   EarthMagneticField: nx4 matrix 3D Earth's background Magnetic field at each point (B,Bx,By,Bz)                                    %%%
%%%   LimMaxZ: height of the floor                                                                                                      %%%
%%%   ForbiddenVolume: Set of diagonally opposing points that define the upper surface of the rectangular prism of a Forbidden Volume   %%%
%%%   Interval: step intervals for each axis                                                                                            %%%
%%%   NumberForbiddenVolume: Number of Forbidden Volumes set                                                                            %%%
%%%   Limits: lateral limits of the scanning volume                                                                                     %%%
%%%   NumberPlots: number of plots created                                                                                              %%%
%%%                                                                                                                                     %%%
%%%   OUTPUTS:                                                                                                                          %%%
%%%                                                                                                                                     %%%
%%%   NumberPlots: number of plots created                                                                                              %%%
%%%                                                                                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [NumberPlots] = PlotData(Path,Mean,EarthMagneticField,LimMaxZ,ForbiddenVolume,Interval,NumberForbiddenVolume,Limits,NumberPlots)
    
    %initialize parameters
    i = 1;
    j = 1;
    k = 1;
    signI = 1;
    signJ = 1;
    %subtract background EarthMagnetiField
	Mean = Mean-EarthMagneticField;
    
    %Organize the magnetic field in matrices in the correct shape and
    %distribution for the plot funstions
    for n = 1:length(Path)
        if n == 1       %for first point
            X(i,j,k) = Path(n,1);
            Y(i,j,k) = Path(n,2);
            Z(i,j,k) = Path(n,3);
            B(i,j,k) = norm(Mean(n,2:4));
            Bx(i,j,k) = Mean(n,2);
            By(i,j,k) = Mean(n,3);
            Bz(i,j,k) = Mean(n,4);
        elseif Path(n,3) == Path(n-1,3) %if it has not changed in axis z
            if Path(n,1) == Path(n-1,1) %if it has not changed in axis x
                if (Path(n,2) == Path(n-1,2)+Interval(2)) || (Path(n,2) == Path(n-1,2)-Interval(2)) %if there is no forbidden volume
                    i = i+signI;
                    X(i,j,k) = Path(n,1);
                    Y(i,j,k) = Path(n,2);
                    Z(i,j,k) = Path(n,3);
                    B(i,j,k) = norm(Mean(n,2:4));
                    Bx(i,j,k) = Mean(n,2);
                    By(i,j,k) = Mean(n,3);
                    Bz(i,j,k) = Mean(n,4);

                else     %if there is forbidden volume
                    excess = abs((Path(n,2)-Path(n-1,2))/Interval(2))-1;
                    for m = 1:excess
                        i = i+signI;
                        X(i,j,k) = Path(n,1)+signI*Interval(2);
                        Y(i,j,k) = Path(n,2);
                        Z(i,j,k) = Path(n,3);
                        B(i,j,k) = NaN;
                        Bx(i,j,k) = NaN;
                        By(i,j,k) = NaN;
                        Bz(i,j,k) = NaN;

                    end
                    i = i+signI;
                    X(i,j,k) = Path(n,1);
                    Y(i,j,k) = Path(n,2);
                    Z(i,j,k) = Path(n,3);
                    B(i,j,k) = norm(Mean(n,2:4));
                    Bx(i,j,k) = Mean(n,2);
                    By(i,j,k) = Mean(n,3);
                    Bz(i,j,k) = Mean(n,4);

                end
            else   %if it has changed in axis X
                signI = signI*(-1);
                if (Path(n,1) == Path(n-1,1)+Interval(1)) || (Path(n,1) == Path(n-1,1)-Interval(1)) %si no hay forbidden volume
                    j = j+signJ;
                    X(i,j,k) = Path(n,1);
                    Y(i,j,k) = Path(n,2);
                    Z(i,j,k) = Path(n,3);
                    B(i,j,k) = norm(Mean(n,2:4));
                    Bx(i,j,k) = Mean(n,2);
                    By(i,j,k) = Mean(n,3);
                    Bz(i,j,k) = Mean(n,4);
                else    %if there is forbidden volume
                    excess = abs((Path(n,1)-Path(n-1,1))/Interval(1))-1;
                    for m = 1:excess
                        j = j+signJ;
                        X(:,j,k) = X(:,j-1,k);
                        Y(:,j,k) = Y(:,j-1,k);
                        Z(:,j,k) = Z(:,j-1,k);
                        B(:,j,k) = NaN;
                        Bx(:,j,k) = NaN;
                        By(:,j,k) = NaN;
                        Bz(:,j,k) = NaN;
                    end
                    j = j+signJ;
                    X(i,j,k) = Path(n,1);
                    Y(i,j,k) = Path(n,2);
                    Z(i,j,k) = Path(n,3);
                    B(i,j,k) = norm(Mean(n,2:4));
                    Bx(i,j,k) = Mean(n,2);
                    By(i,j,k) = Mean(n,3);
                    Bz(i,j,k) = Mean(n,4);
                end
            end
        else    %if it has changed in axis z
            signI = signI*(-1);
            signJ = signJ*(-1);
            k = k+1;
            X(i,j,k) = Path(n,1);
            Y(i,j,k) = Path(n,2);
            Z(i,j,k) = Path(n,3);
            B(i,j,k) = norm(Mean(n,2:4));
            Bx(i,j,k) = Mean(n,2);
            By(i,j,k) = Mean(n,3);
            Bz(i,j,k) = Mean(n,4);
        end
    end
    
    
    
    
    
    
    tf = 1;
    while tf == 1
        %Select the type of plot
        Options = {'Quiver plot','Contour plot','Streamline plot'};
        [Option,tf] = listdlg('ListString',Options,'SelectionMode','single','Name','Choose the type of plot','ListSize',[500,200]);

        if Option == 1  %quiver plot
            tf2 = 1;
            while tf2 == 1
                %Select Proportional scale or logarithmic scale
                Options = {'Proportional values','Logarithmic scaled values'};
                [Option2,tf2] = listdlg('ListString',Options,'SelectionMode','single','Name','Choose the type of quiver plot','ListSize',[500,200]);
                if Option2 == 1
                    figure(NumberPlots)
                    %call PlotQuiver function
                    PlotQuiver(Path,Mean,LimMaxZ,ForbiddenVolume,Interval,NumberForbiddenVolume,Limits,Option2);
                    view(3);
                    title('Magnetic field quiver plot');
                    NumberPlots = NumberPlots + 1;
                    
                elseif Option2 == 2
                    figure(NumberPlots)
                    %call quiverInLogScale function, which converts the data to log scale
                    [MeanLog(:,2), MeanLog(:,3), MeanLog(:,4)] = quiverInLogScale(Mean(:,2), Mean(:,3), Mean(:,4));
                    %call PlotQuiver function
                    PlotQuiver(Path,MeanLog,LimMaxZ,ForbiddenVolume,Interval,NumberForbiddenVolume,Limits,Option2);
                    title('Magnetic field quiver plot in logarithmic scale');
                    view(3);
                    NumberPlots = NumberPlots + 1;
                end
            end
        elseif Option == 2  %contour plot
            tf2 = 1;
            while tf2 == 1
                %Select whether the planes are represented individually or stacked
                Options = {'Individual contour planes','Stacked contour planes'};
                [Option2,tf2] = listdlg('ListString',Options,'SelectionMode','single','Name','Choose the type of contour plot','ListSize',[500,200]);
                if Option2 == 2
                    Ready = 0;

                    while Ready == 0
                        %set distance between stacked planes
                        description = {'Set multiple by which distance between planes will be plot in relation to real distance'};
                        titles = 'Set multiple by which distance between planes will be plot in relation to real distance';
                        Multiplestring = inputdlg(description,titles,[1 100],{'1'});

                        if size(Multiplestring) == [0 0]
                            Ready = 1;
                            Multiple = [];
                            tf3 = 0;
                        else
                            Answer = str2num(Multiplestring{1});
                            if isempty(Answer) == 1
                                [~,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The inputs are not valid. Click continue','ListSize',[500,50]);
                                Multiple = [];
                            elseif Answer>0
                                Multiple = Answer;
                                Ready = 1;
                                tf3 = 1;
                            else
                                [~,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The input must be a positive number. Click continue','ListSize',[500,50]);
                            end
                        end
                    end
                elseif Option2 == 1
                    tf3 = 1;
                else
                    tf3 = 0;
                end
                if tf3 == 1                     
                    Options = {'B','Bx','By','Bz'};
                    [SelectedField,tf3] = listdlg('ListString',Options,'SelectionMode','single','Name','Choose the component of magnetic field to be plotted','ListSize',[500,200]);
                end
                if tf3 == 1
                    if SelectedField == 1
                        Options = {'Proportional','Logarithmic'};
                        [SelectedScale,tf3] = listdlg('ListString',Options,'SelectionMode','single','Name','Choose the type of scale','ListSize',[500,200]);
                    else
                        SelectedScale = 1;
                    end
                end
                if tf3 == 1
                    
                    MatrixMagneticFields(:,:,:,1) = B;
                    MatrixMagneticFields(:,:,:,2) = Bx;
                    MatrixMagneticFields(:,:,:,3) = By;
                    MatrixMagneticFields(:,:,:,4) = Bz;
                    
                    if SelectedScale == 1
                        if Option2 == 2
                            figure(NumberPlots)
                        end
                        if SelectedField == 1
                            Cmin = min(B(:));
                            Cmax = max(B(:));
                        elseif SelectedField == 2
                            Cmin = min(Bx(:));
                            Cmax = max(Bx(:));
                        elseif SelectedField == 3
                            Cmin = min(By(:));
                            Cmax = max(By(:));
                        elseif SelectedField == 4
                            Cmin = min(Bz(:));
                            Cmax = max(Bz(:));
                        end
                        for z=1:size(B,3)
                            if Option2 == 1
                                figure(NumberPlots)
                            end
                            %Plot contour
                            [~,h] = contourf(X(:,:,z),Y(:,:,z),MatrixMagneticFields(:,:,z,SelectedField));
                            
                            if Option2 == 1
                                caxis([Cmin,Cmax]);
                            end
                            if Option2 == 2
                                h.ContourZLevel = (Multiple*Z(1,1,z));
                            end
                            axis equal
                            if Option2 == 2
                                hold on
                            else
                                c = colorbar;
                                c.Label.String = 'Magnetic field (T)';
                                if SelectedField == 1
                                    title(['B (T) Colormap at ', num2str(Z(1,1,z)), 'mm height']);
                                elseif SelectedField == 2
                                    title(['Bx (T) Colormap at ', num2str(Z(1,1,z)), 'mm height']);
                                elseif SelectedField == 3
                                    title(['By (T) Colormap at ', num2str(Z(1,1,z)), 'mm height']);
                                elseif SelectedField == 4
                                    title(['Bz (T) Colormap at ', num2str(Z(1,1,z)), 'mm height']);
                                end
                                
                                xlabel('X axis (mm)');
                                ylabel('Y axis (mm)');
                                NumberPlots = NumberPlots + 1;
                            end
                        end
                        if Option2 == 2
                            c = colorbar;
                            c.Label.String = 'Magnetic field (T)';
                            if SelectedField == 1
                                title('B (T) Colormap');
                            elseif SelectedField == 2
                                title('Bx (T) Colormap');
                            elseif SelectedField == 3
                                title('By (T) Colormap');
                            elseif SelectedField == 4
                                title('Bz (T) Colormap');
                            end
                            
                            xlabel('X axis (mm)');
                            ylabel('Y axis (mm)');
                            zlabel(['Z axis (mm). Heights are multiplied by a factor of: ', num2str(Multiple)]);
                            view(3);
                            NumberPlots = NumberPlots + 1;
                        end
                    else
                        if Option2 == 2
                            figure(NumberPlots)
                        end
                        if SelectedField == 1
                            Cmin = min(log(B(:)));
                            Cmax = max(log(B(:)));
                        end
                        figure(NumberPlots)
                        for z=1:size(B,3)
                            if Option2 == 1
                                figure(NumberPlots)
                            end
                            %Plot contour
                            [~,h] = contourf(X(:,:,z),Y(:,:,z),log(MatrixMagneticFields(:,:,z,SelectedField)));
                            if Option2 == 1
                                caxis([Cmin,Cmax]);
                            end
                            if Option2 == 2
                                h.ContourZLevel = (Multiple*Z(1,1,z));
                            end
                            axis equal
                            if Option2 == 2
                                hold on
                            else
                                c = colorbar;
                                c.Label.String = 'Log(Magnetic field) Log(T)';
                                title(['log(B) Log(T) Colormap at ', num2str(Z(1,1,z)), 'mm height']);
                                xlabel('X axis (mm)');
                                ylabel('Y axis (mm)');
                                NumberPlots = NumberPlots + 1;
                            end
                        end
                        if Option2 == 2
                            c = colorbar;
                            c.Label.String = 'Log(Magnetic field) Log(T)';
                            title('log(B) Log(T) Colormap');
                            xlabel('X axis (mm)');
                            ylabel('Y axis (mm)');
                            zlabel(['Z axis (mm). Heights are multiplied by a factor of: ', num2str(Multiple)]);
                            view(3);
                            NumberPlots = NumberPlots + 1;
                        end
                    end
                end

            end
        elseif Option == 3  %streamline plot
            Ready = 0;
            while Ready == 0
                %set density of streamlines in each axis
                description = {'% in X axis','% in Y axis','% in Z axis'};
                titles = 'Set % of lines (with respect to number of measuring grid points. Must be greater than 0% but can be greater than 100%)';
                MultipleXYZstring = inputdlg(description,titles,[1 130;1 130;1 130],{'100','100','100'});

                if size(MultipleXYZstring) == [0 0]
                    Ready = 1;
                    MultipleXYZ = [];
                    tf3 = 0;
                else
                    for s = 1:3
                        Answer = str2num(MultipleXYZstring{s});
                        if isempty(Answer) == 1
                            [~,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The inputs are not valid. Click continue','ListSize',[500,50]);
                            MultipleXYZ = [];
                            Ready = 0;
                            tf3 = 0;
                            break
                        elseif Answer>0
                            MultipleXYZ(s) = Answer;
                            Ready = 1;
                            tf3 = 1;
                        else
                            [~,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The input must be a positive number. Click continue','ListSize',[500,50]);
                            Ready = 0;
                            tf3 = 0;
                        end
                    end
                end
            end
            if tf3 == 1
                figure(NumberPlots)
                [startX,startY,startZ] = meshgrid(min(X(:)):100/MultipleXYZ(1)*Interval(1):max(X(:)),min(Y(:)):100/MultipleXYZ(2)*Interval(2):max(Y(:)),min(Z(:)):100/MultipleXYZ(3)*Interval(3):max(Z(:)));
                verts = stream3(X,Y,Z,Bx,By,Bz,startX,startY,startZ);
                streamline(verts)   %Plot streamlines
                view(3)
                LimMinX = min(ForbiddenVolume(1,1,:))-str2num(Limits{1});
                LimMinY = min(ForbiddenVolume(2,1,:))-str2num(Limits{2});

                hold on
                %Plot Forbidden Volumes
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
                
                title('Streamlines');
                xlabel(['X axis (mm)   (' num2str(MultipleXYZ(1)) '% streamline density)']);
                ylabel(['Y axis (mm)   (' num2str(MultipleXYZ(2)) '% streamline density)']);
                zlabel(['Z axis (mm)   (' num2str(MultipleXYZ(3)) '% streamline density)']);
                axis equal
                
                NumberPlots = NumberPlots + 1;
                
            end
            
        end

    end
    

end