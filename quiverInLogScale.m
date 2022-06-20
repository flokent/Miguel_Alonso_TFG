%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                                                                                     %%%
%%%   quiverInLogScale function                                                                                                         %%%
%%%                                                                                                                                     %%%
%%%   INPUTS:                                                                                                                           %%%
%%%                                                                                                                                     %%%
%%%   u: Bx                                                                                                                             %%%
%%%   v: By                                                                                                                             %%%
%%%   w: Bz                                                                                                                             %%%
%%%                                                                                                                                     %%%
%%%   OUTPUTS:                                                                                                                          %%%
%%%                                                                                                                                     %%%
%%%   uLog: log(Bx)                                                                                                                     %%%
%%%   vLog: log(By)                                                                                                                     %%%
%%%   wLog: log(Bz)                                                                                                                     %%%
%%%                                                                                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [uLog, vLog, wLog] =  quiverInLogScale(u, v, w)

R = zeros(length(u),1);
for i=1:length(u)
R(i)= sqrt(u(i)^2+v(i)^2+w(i)^2); % Compute B at every point
end

minR = min(min(R(R~=0))); % Find the minimum magnitude, important in the case that it is below 1, so the log will not switch sign.

% Calculates the normalized versions of u and v, this will keep the
% original angles.

uNorm = u./R;
vNorm = v./R;
wNorm = w./R;

% Calculates the log versions of u and v.
uLog = log(R/minR).*uNorm;
vLog = log(R/minR).*vNorm;
wLog = log(R/minR).*wNorm;

end