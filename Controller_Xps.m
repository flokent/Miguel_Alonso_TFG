%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     MAGENTIC FIELD SCANNER SOFTWARE                   %%%
%%%                                                                       %%%
%%%                                                                       %%%
%%% Make sure this file is in the same folder as the rest of functions.   %%%
%%%                                                                       %%%
%%% Make sure the XPS-Q8 drivers are in the directory path of this file.  %%%
%%% If it is not, include it in the path by going to 'HOME' > 'Set Path'. %%%
%%%                                                                       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INITIALIZATION

clear;clc;

%Connect to Magnetometer

f71 = tcpip('192.168.0.12',7777);
fopen(f71);
fprintf(f71,'*IDN?');
fscanf(f71);
fprintf(f71,'*RST');

% Load the library

XPS_load_drivers ;

% Set connection parameters

IP = '192.168.0.254' ;

Port = 5001 ;

TimeOut = 60.0 ;

% Connect to XPS

socketID = TCP_ConnectToServer (IP, Port, TimeOut) ;

% Check connection

if (socketID < 0)

 disp 'Connection to XPS failed, check IP & Port' ;

 return ;

end

% Define the positioner

group = {'GROUP1','GROUP2','GROUP3'};



positioner = {'GROUP1.POSITIONER','GROUP2.POSITIONER','GROUP3.POSITIONER'} ;


% Kill the group

for i = 1:3
[errorCode] = GroupKill(socketID, group{i}) ; 


    if (errorCode ~= 0)

     disp (['Error ' num2str(errorCode) ' occurred while doing GroupKill ! ']) ;

     return ;

    end
end

% Initialize the group
for i = 1:3
[errorCode] = GroupInitialize(socketID, group{i}) ; 

    if (errorCode ~= 0)

     disp (['Error ' num2str(errorCode) ' occurred while doing GroupInitialize ! ']) ;

     return ;

    end
end

% Home search
for i = 3:-1:1
[errorCode] = GroupHomeSearch(socketID, group{i}) ; 

    if (errorCode ~= 0)

     disp (['Error ' num2str(errorCode) ' occurred while doing GroupHomeSearch ! ']) ;

     return ;

    end
end

%Initialize parameters

NumberForbiddenVolume = 0;
AskFloor = 0;
AskForbiddenVolume = 0;
AskLimits = 0;
AskIntervals = 0;
AskSamples = 0;
AskData = 0;
AskMFE = 0;
LimMaxZ = 1000;
ForbiddenVolume = [];
Dimension = [];

Origin = zeros(1,3);
AskOrigin = 0;
AskDimension = 0;
Open = 2;
NumberPlots = 1;

%MAIN PROGRAM

while Open == 2

    %Select method of acquiring data
    Options = {'Exit program','Physical grid method','No physical grid method','Import data'};
    [Option,tf] = listdlg('ListString',Options,'SelectionMode','single','Name','Choose what you want to do','ListSize',[300,100]);

    if Option == 1    %exit program
        [Open,tf] = listdlg('ListString',{'Yes','No'},'SelectionMode','single','Name','Are you sure you want to exit the program?','ListSize',[500,50],'InitialValue',2);
        if tf == 0
            Open = 2;
        end
    elseif Option == 2    %Physical grid method
        
        GridOpen = 2;
        
        while GridOpen == 2
            
            %To avoid certain actions to be taken that can not be executed
            %before certain parameters are set, each option is only
            %available when the required parameters to execute it have been
            %defined
            
            if AskOrigin == 0
                Options = {'Return to main menu','Set origin of the grid'};
            elseif AskDimension == 0
                Options = {'Return to main menu','Change origin of the grid','Set dimensions of the grid'};
            elseif AskForbiddenVolume == 0
                Options = {'Return to main menu','Change origin of the grid','Change dimensions of the grid','Set forbidden volume'};
            elseif AskLimits == 0
                Options = {'Return to main menu','Change origin of the grid','Change dimensions of the grid','Set another forbidden volume','Delete a forbidden volume','Set limits'};
            elseif AskIntervals == 0
                Options = {'Return to main menu','Change origin of the grid','Change dimensions of the grid','Set another forbidden volume','Delete a forbidden volume','Change limits','Set intervals'};
            elseif AskSamples == 0
                Options = {'Return to main menu','Change origin of the grid','Change dimensions of the grid','Set another forbidden volume','Delete a forbidden volume','Change limits','Change intervals','Set number of samples'};
            elseif AskData == 0
                Options = {'Return to main menu','Change origin of the grid','Change dimensions of the grid','Set another forbidden volume','Delete a forbidden volume','Change limits','Change intervals','Change number of samples','Measure magnetic field'};
            elseif AskMFE == 0
                Options = {'Return to main menu','Change origin of the grid','Change dimensions of the grid','Set another forbidden volume','Delete a forbidden volume','Change limits','Change intervals','Change number of samples','Measure magnetic field','Measure Earth Magnetic Field'};
            else
                Options = {'Return to main menu','Change origin of the grid','Change dimensions of the grid','Set another forbidden volume','Delete a forbidden volume','Change limits','Change intervals','Change number of samples','Measure magnetic field','Measure Earth Magnetic Field','Plot data','Save data in file'};
            end

            [OptionChosen,tf] = listdlg('ListString',Options,'SelectionMode','single','Name','Choose what you want to do','ListSize',[500,200]);
            
             if OptionChosen == 1    %Exit to main menu
                [GridOpen,tf] = listdlg('ListString',{'Yes','No'},'SelectionMode','single','Name','Are you sure you want to return to the main menu?','ListSize',[500,50],'InitialValue',2);
                if tf == 0
                    GridOpen = 2;
                end

            elseif OptionChosen == 2    %Set origin
                [Origin,AskOrigin,AskDimension,AskForbiddenVolume,ForbiddenVolume,NumberForbiddenVolume] = SetOrigin(socketID,positioner,LimMaxZ,AskOrigin,AskDimension,AskForbiddenVolume,ForbiddenVolume,NumberForbiddenVolume);
                
             elseif OptionChosen == 3   %Set dimensions
                [Dimension] = SetDimension(socketID,positioner,Origin);
                if isempty(Dimension) == 0
                    AskDimension = 1;
                else
                    AskDimension = 0;
                end
                
             elseif OptionChosen == 4   %Set Forbidden Volume
               [NumberForbiddenVolume,AskForbiddenVolume,ForbiddenVolume] = SetForbiddenVolume(Option,socketID,positioner,LimMaxZ,OptionChosen,NumberForbiddenVolume,ForbiddenVolume,Origin,Dimension,AskForbiddenVolume);
                 
             elseif OptionChosen == 5   %Delete Forbidden Volume
                [ForbiddenVolume, NumberForbiddenVolume] = DeleteForbiddenVolume(ForbiddenVolume,Origin(3),NumberForbiddenVolume);
                if NumberForbiddenVolume == 0
                    AskForbiddenVolume = 0;
                end
                
             elseif OptionChosen == 6    %Set limits
                [Limits] = SetLimits;
                if isempty(Limits) == 0
                    AskLimits = 1;
                else
                    AskLimits = 0;
                end
                
                
             elseif OptionChosen == 7    %Set intervals
                [Interval] = SetIntervals;
                if isempty(Interval) == 0
                    AskIntervals = 1;
                else
                    AskIntervals = 0;
                end
                
                
             elseif OptionChosen == 8   %Set number of samples
                [NumberSamples] = SetNumberSamples;
                if isempty(NumberSamples) == 0
                    AskSamples = 1;
                else
                    AskSamples = 0;
                end
                
             elseif OptionChosen == 9    %Measure magnetic field
                [Path,Mean] = MeasureMagneticField(f71,socketID,positioner,ForbiddenVolume,Limits,NumberSamples,NumberForbiddenVolume,Interval,Origin(3));
                AskData = 1;
                
             elseif OptionChosen == 10  %Measure Earth Magnetic field
                [indx,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','Remove the object before performing the measurements. Click continue when ready','ListSize',[700,50]);
                if indx == 1
                    [Path,EarthMagneticField] = MeasureMagneticField(f71,socketID,positioner,ForbiddenVolume,Limits,NumberSamples,NumberForbiddenVolume,Interval,Origin(3));
                    AskMFE = 1;
                end 
            elseif OptionChosen == 11   %Plot data
                [NumberPlots] = PlotData(Path,Mean,EarthMagneticField,Origin(3),ForbiddenVolume,Interval,NumberForbiddenVolume,Limits,NumberPlots);
            
            elseif OptionChosen == 12  %Save Data
                [Folder] = SaveData;
                
                if size(Folder) ~= [0 0]
                    save(Folder{1});
                end
            end
        end
        
    elseif Option == 3    %No physical grid method

        NoGridOpen = 2;

        while NoGridOpen == 2
            
            %To avoid certain actions to be taken that can not be executed
            %before certain parameters are set, each option is only
            %available when the required parameters to execute it have been
            %defined
            
            if AskFloor == 0
                Options = {'Return to main menu','Set floor'};
            elseif AskForbiddenVolume == 0
                Options = {'Return to main menu','Change floor','Set forbidden volume'};
            elseif AskLimits == 0
                Options = {'Return to main menu','Change floor','Set another forbidden volume','Delete a forbidden volume','Set limits'};
            elseif AskIntervals == 0
                Options = {'Return to main menu','Change floor','Set another forbidden volume','Delete a forbidden volume','Change limits','Set intervals'};
            elseif AskSamples == 0
                Options = {'Return to main menu','Change floor','Set another forbidden volume','Delete a forbidden volume','Change limits','Change intervals','Set number of samples'};
            elseif AskData == 0
                Options = {'Return to main menu','Change floor','Set another forbidden volume','Delete a forbidden volume','Change limits','Change intervals','Change number of samples','Measure magnetic field'};
            elseif AskMFE == 0
                Options = {'Return to main menu','Change floor','Set another forbidden volume','Delete a forbidden volume','Change limits','Change intervals','Change number of samples','Measure magnetic field','Measure Earth Magnetic Field'};
            else
                Options = {'Return to main menu','Change floor','Set another forbidden volume','Delete a forbidden volume','Change limits','Change intervals','Change number of samples','Measure magnetic field','Measure Earth Magnetic Field','Plot data','Save data in file'};
            end

            [OptionChosen,tf] = listdlg('ListString',Options,'SelectionMode','single','Name','Choose what you want to do','ListSize',[500,200]);

            if OptionChosen == 1    %Exit to main menu
                [NoGridOpen,tf] = listdlg('ListString',{'Yes','No'},'SelectionMode','single','Name','Are you sure you want to return to the main menu?','ListSize',[500,50],'InitialValue',2);
                if tf == 0
                    NoGridOpen = 2;
                end

            elseif OptionChosen == 2    %Set floor
                i = 1;
                [Return] = MoveArmManually(socketID,positioner,OptionChosen,i,LimMaxZ);
                if Return == 0
                    [Error, LimMaxZ] = GroupPositionCurrentGet (socketID, positioner{3},1);
                    AskFloor = 1;
                end

            elseif OptionChosen == 3    %Set Forbidden Volume
                [NumberForbiddenVolume,AskForbiddenVolume,ForbiddenVolume] = SetForbiddenVolume(Option,socketID,positioner,LimMaxZ,OptionChosen,NumberForbiddenVolume,ForbiddenVolume,Origin,Dimension);

            elseif OptionChosen == 4    %Delete a Forbidden Volume
                [ForbiddenVolume, NumberForbiddenVolume] = DeleteForbiddenVolume(ForbiddenVolume,LimMaxZ,NumberForbiddenVolume);

                if NumberForbiddenVolume == 0
                    AskForbiddenVolume = 0;
                end

            elseif OptionChosen == 5    %Set Limits
                [Limits] = SetLimits;
                if isempty(Limits) == 0
                    AskLimits = 1;
                else
                    AskLimits = 0;
                end

            elseif OptionChosen == 6    %Set intervals
                [Interval] = SetIntervals;
                if isempty(Interval) == 0
                    AskIntervals = 1;
                else
                    AskIntervals = 0;
                end

            elseif OptionChosen == 7    %Set number samples
                [NumberSamples] = SetNumberSamples;
                if isempty(NumberSamples) == 0
                    AskSamples = 1;
                else
                    AskSamples = 0;
                end

            elseif OptionChosen == 8    %Measure magnetic field
                [Path,Mean] = MeasureMagneticField(f71,socketID,positioner,ForbiddenVolume,Limits,NumberSamples,NumberForbiddenVolume,Interval,LimMaxZ);
                AskData = 1;
                
            elseif OptionChosen == 9    %Measure magnetic field earth
                %Perform the scanning process again but without the sample,
                %to measure Earth's background magnetic field
                [indx,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','Remove the object before performing the measurements. Click continue when ready','ListSize',[700,50]);
                if indx == 1
                    [Path,EarthMagneticField] = MeasureMagneticField(f71,socketID,positioner,ForbiddenVolume,Limits,NumberSamples,NumberForbiddenVolume,Interval,LimMaxZ);
                    AskMFE = 1;
                end
            elseif OptionChosen == 10    %Plot data
                [NumberPlots] = PlotData(Path,Mean,EarthMagneticField,LimMaxZ,ForbiddenVolume,Interval,NumberForbiddenVolume,Limits,NumberPlots);
            
            elseif OptionChosen == 11    %Save data in file
                
                [Folder] = SaveData;
                if size(Folder) ~= [0 0]
                    save(Folder{1});
                end
            end
        end
        
    elseif Option == 4  %Load data from previous scans
        
        if exist('Data','dir')==7	%Checks wheter the 'Data' file exists
            Folder = pwd;
            Folder = strcat(Folder,'\Data');
            [FileName,Directory] = uigetfile({'*mat'},'Select a file',Folder);  %Slect the desired file
            if (any(FileName ~= 0) == 1 && any(Directory ~= 0) == 1)        %if a file has been selected
                [SureLoad,tf] = listdlg('ListString',{'Yes','No'},'SelectionMode','single','Name','Are you sure you want to load these variables? Any current variables will be deleted. Make sure to save first','ListSize',[700,50],'InitialValue',2);
                if tf == 0
                    SureLoad = 2;
                end
                if SureLoad == 1
                    load(strcat(Directory,FileName));   %Load file
                    NumberPlots = 1;
                end
            end
        else   %'Data' folder can not be found
            [~,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','"Data" folder can not be found','ListSize',[500,50]);
        end
        Open = 2;   %In case the loaded data comes from the 'PROVISIONAL DATA' folder,
                    %as it is a previously closed program and not changing this variable would close the program
        
        %Initialization process
        socketID = TCP_ConnectToServer (IP, Port, TimeOut) ;
        f71 = tcpip('192.168.0.12',7777);
        fopen(f71);
        fprintf(f71,'*IDN?');
        fscanf(f71);
        fprintf(f71,'*RST');
    end
    
end

%Save the data in a 'PROVISIONAL DATA' file in case the user has forgotten
%to save the data. This file is overwritten every time the program is
%closed, thus the data can only be retrieved before the program is started
%again
if exist('Data','dir')~=7
    mkdir('Data')
end

if exist('Data\PROVISIONAL DATA','dir') ~=7
    mkdir('Data\PROVISIONAL DATA')
end

save('Data\PROVISIONAL DATA\PROVISIONAL_DATA.mat');


%Takes the positioner back to the 'HOME' position
[errorCode] = GroupMoveAbsolute(socketID, positioner{3}, 0) ;       %first axis Z to ensure no collition
[errorCode] = GroupMoveAbsolute(socketID, positioner{1}, 0) ;
[errorCode] = GroupMoveAbsolute(socketID, positioner{2}, 0) ;

%Close connection with the XPS-Q8
TCP_CloseSocket(socketID);