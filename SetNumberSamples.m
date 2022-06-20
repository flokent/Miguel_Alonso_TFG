%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                                                                                     %%%
%%%   SetNumberSamples function                                                                                                         %%%
%%%                                                                                                                                     %%%
%%%   INPUTS:                                                                                                                           %%%
%%%                                                                                                                                     %%%
%%%   OUTPUTS:                                                                                                                          %%%
%%%                                                                                                                                     %%%
%%%   NumberSamples: number of data samples the probe has to measure at each point                                                      %%%
%%%                                                                                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [NumberSamples] = SetNumberSamples
    
    Ready = 0;

    while Ready == 0
        %Ask input to the user of the number of samples
        description = {'Set the number of data samples'};
        title = 'Set the number of data samples';
        NumberSamplesstring = inputdlg(description,title,[1 55]);

        if size(NumberSamplesstring) == [0 0] %if NumberSamplesstring is a 0x0 cell the user has clicked 'cancel'
            Ready = 1;
            NumberSamples = [];
        else   %the user has provided an input
            Answer = str2num(NumberSamplesstring{1});   %if NumberSamplesstring{i} is not a number or is blank 'Answer' is to be empty
            if isempty(Answer) == 1 || round(Answer) ~= Answer   %is 'Answer' is empty or is a decimal number
                [~,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The inputs are not valid. Click continue','ListSize',[500,50]);
                NumberSamples = []; %not save the answer
            elseif Answer>0   %else if 'Answer' is positive
                NumberSamples = Answer;
                Ready = 1;
            else   %if 'Answer' is negative
                [~,~] = listdlg('ListString',{'Continue'},'SelectionMode','single','Name','The input must be a positive number. Click continue','ListSize',[500,50]);
            end
        end
    end
end

