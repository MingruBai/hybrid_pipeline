function [ points3d, points2d ] = depth2points3d( depthInpaint, data, crop )
%DEPTH2POINTS3D Summary of this function goes here
%   Detailed explanation goes here
if nargin<=2
    crop = [1 1 size(depthInpaint,2) size(depthInpaint,1)];
end

K = data.K;
depthInpaintsize = size(depthInpaint);

cx = K(1,3); cy = K(2,3);  
fx = K(1,1); fy = K(2,2); 
invalid = depthInpaint==0 | isnan(depthInpaint);

%3D points
[x,y] = meshgrid(1:depthInpaintsize(2), 1:depthInpaintsize(1));   
valid = ~invalid & x>=crop(1) & x<=crop(3) & y>=crop(2) & y<=crop(4);

x = x(valid);
y = y(valid);
depth = depthInpaint(valid);

x3 = (x-cx).*depth*1/fx;  
y3 = (y-cy).*depth*1/fy;  
z3 = depth;  

points3d = [x3(:) z3(:) -y3(:)];

points3d = (data.Rtilt*points3d')';
points2d = [x(:) y(:)];

end

