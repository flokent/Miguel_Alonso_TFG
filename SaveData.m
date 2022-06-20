%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                                                                                     %%%
%%%   SaveData function                                                                                                                 %%%
%%%                                                                                                                                     %%%
%%%   OUTPUTS:                                                                                                                          %%%
%%%                                                                                                                                     %%%
%%%   Folder: folder directory where the data is to be saved                                                                            %%%                                                                          
%%%                                                                                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Folder] = SaveData
    check = 1;
    if exist('Data','dir')~=7       %checks if the folder 'Data' exists
        mkdir('Data')               %if folder 'Data' does not exist, it creates it
    end
    
    while check == 1
        FileName = inputdlg('Set name','Choose name',[1 50]);
        if size(FileName) == [0 0]      %checks if user cancelled
            check = 0;
            Folder = [];
        else
            List = ls('Data');          %gets names files in Data folder
            Listcell = cellstr(List);   %converts it into cell array
            if any(strcmp(FileName,Listcell))    %checks if the name chosen has already been used
                [~,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The name chosen has already been used. Use a different name','ListSize',[500,50]);
            else  %if it has not been used
                NameVariables = FileName;
                FileName = strcat('Data\',FileName);    %creates directory
                mkdir(FileName{1})  %creates folder with selected name within the 'Data' folder
                Folder = pwd;    %gets current directory
                Folder = strcat(Folder,'\',FileName,'\',regexprep(NameVariables,' ','_'),'.mat');    %creates directory
                check = 0;
            end
        end
    end
end