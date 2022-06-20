%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                                                                                     %%%
%%%   quivercolorsamelength function                                                                                                    %%%
%%%                                                                                                                                     %%%
%%%   INPUTS:                                                                                                                           %%%
%%%                                                                                                                                     %%%
%%%   x: X coordinate of the path                                                                                                       %%%
%%%   y: X coordinate of the path                                                                                                       %%%
%%%   z: X coordinate of the path                                                                                                       %%%
%%%   u: Bx                                                                                                                             %%%
%%%   v: By                                                                                                                             %%%
%%%   w: Bz                                                                                                                             %%%
%%%   separacion: minimum step size                                                                                                     %%%
%%%   Option2: whether the data is in proportional or logarithmic scale                                                                 %%%
%%%                                                                                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function quivercolorsamelength(x, y, z, u, v, w, separacion,Option2)

c = colormap(jet);  %select colormap

ncolor = length (c);%number of colors in colormap

R = zeros(length(u),1); 
for i=1:length(u)
    R(i)= sqrt(u(i)^2+v(i)^2+w(i)^2);   %compute B at each point
end
maxR = max(R);  %maximum value of B
minR = min(R);  %minimum value of B

color = round(R./maxR*ncolor);  %assign a color number of the colormap to each point depending on the value of B of said point
color(color == 0) = 1;

%make all arrows same length but respecting the correct direction
uNorm = u./R;
vNorm = v./R;
wNorm = w./R;

u = uNorm.*separacion;
v = vNorm.*separacion;
w = wNorm.*separacion;

hold on
%3D graph the magnetic field through same selength arrows with different
%colors which represent the magnetic field intensity
for i = 1:length(u)
        quiver3(x(i), y(i), z(i), u(i), v(i), w(i), 0, 'Color', c(color(i),:), 'MaxHeadSize', 0.5);
        hold on
end
h = colorbar;   %set colorbar
if Option2 == 1
    ylabel(h,'Magnetic field (T)');
else
    ylabel(h,'Log(Magnetic field) Log(T)');
end

caxis([minR maxR]) 


axis equal

end