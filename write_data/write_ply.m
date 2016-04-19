function write_ply(plyPath, allV, allF,imageData)


disp('Writing scene to ply... ');

renderF = [allF allF(:,1)];
K = imageData.K;
P = K*[inv(imageData.Rtilt*[1 0 0;0 0 1;0 1 0]) zeros(3,1)];
img = imread(imageData.depthpath);
imsize = size(img);

result = RenderMex(P, imsize(2), imsize(1), allV', uint32(renderF'-1))';
z_near = 0.3;
depth = z_near./double(1-double(result)/2^32);
depth(depth>8) = 0;
[rgb,points3dall, XYZ]=read_3d_pts_general(depth,imageData.K,size(depth),imageData.rgbpath);
points3dall = (imageData.Rtilt*points3dall')';
points2ply(plyPath, points3dall');

end