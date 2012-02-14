function [dmin] = distance_function3d(x,X1,Y1,Z1)
dmin = inf;
if( size(X1,1) >= size(X1,2)), error( 'wrong dimensions for X' ), end

for i=1:size(X1,2)
   dx = X1(i) - x(1);
   dy = Y1(i) - x(2);
   dz = Z1(i) - x(3);
   d = sqrt(dx^2+dy^2+dz^2);
   if d<dmin
       dmin=d;
   end
end