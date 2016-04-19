%function wall_inside_bb = get_wall_points(imageData)


wallData = imageData.gtCorner3D;

[rgb,points3d,depthInpaint,imsize,XYZ]=read3dPoints(imageData);

wall_inside_bb = zeros(length(points3d),1);

floor_level = min(wallData(3,1),wallData(3,size(wallData,2)));

floorPoints = points3d(points3d(:,3) > floor_level - 0.1 & points3d(:,3) < floor_level + 0.1, :);

[floor_best,floor_n_best,floor_ro_best,X_best,Y_best,Z_best,error_best,sample_best]=local_ransac_tim(floorPoints,100,5,0.02,length(floorPoints)/2);
floor_mean = mean(floor_best);

a = floor_n_best(1);
b = floor_n_best(2);
c = floor_n_best(3);
d = - floor_mean * floor_n_best;

floorCorners = wallData(:,int32(wallData(3,:)) == int32(floor_level));
floorCorners(3,:) = -(floorCorners(1,:)*a + floorCorners(2,:)*b + d)/c;

floorV = floorCorners';
floorF = 1:length(floorV);

floorDepth = render_depth(floorV, floorF, imageData);

wallDepth = floorDepth;
% dotX = points3d(:,1) * floor_n_best(1);
% dotY = points3d(:,2) * floor_n_best(2);
% dotZ = points3d(:,3) * floor_n_best(3);
% dist = abs(dotX + dotY + dotZ - floor_ro_best);
% 
% floor_thres = 0.02;
% wall_inside_bb(dist < floor_thres) = 1;
%end