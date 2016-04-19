function [ depth ] = obj2im( objname, data )
%OBJ2IM Summary of this function goes here
%   Detailed explanation goes here
img = imread(data.depthpath);
imsize = size(img);

K = data.K;
P = K*[inv(data.Rtilt*[1 0 0;0 0 1;0 1 0]) zeros(3,1)];
obj = objLoader(objname);
result = RenderMex(P, imsize(2), imsize(1), obj.vmat, uint32(obj.fmat))';

z_near = 0.3;
depth = z_near./(1-double(result)/2^32);

end

