function roomDepth = get_wall_depth(imageData)

wallData = imageData.gtCorner3D;

[rgb,points3d,depthInpaint,imsize,XYZ]=read3dPoints(imageData);

floor_level = min(wallData(3,1),wallData(3,size(wallData,2)));

floorPoints = points3d(points3d(:,3) > floor_level - 0.1 & points3d(:,3) < floor_level + 0.1, :);

if length(floorPoints) >= 100
    [floor_best,floor_n_best,floor_ro_best,X_best,Y_best,Z_best,error_best,sample_best,success]=local_ransac_bai(floorPoints,100,1000,0.02,length(floorPoints)/2);
else
    success = 0;
end

if success
    floor_mean = mean(floor_best);
    a = floor_n_best(1);
    b = floor_n_best(2);
    c = floor_n_best(3);
    d = - floor_mean * floor_n_best;
    floorCorners = wallData(:,int32(wallData(3,:)) == int32(floor_level));
    floorCorners(3,:) = -(floorCorners(1,:)*a + floorCorners(2,:)*b + d)/c;
else
    floorCorners = wallData(:,int32(wallData(3,:)) == int32(floor_level));
end

floorV = floorCorners';
floorF = delaunay(floorV(:,1:2));

floorDepth = render_depth(floorV, floorF, imageData);

%get vertical walls:
n = size(wallData,2);
wallList = [];
for i = 2:n/2
    wallF = [i-1, i, i+n/2, i-1+n/2];
    wallList = [wallList;wallF];
end
fend = [1,n/2+1,n,n/2];
wallList = [wallList;fend];

roomV = [];
roomF = [];

for i = 1:size(wallList,1)
    wallF = wallList(i,:);
    wallV = wallData(:,wallF)';
    [wall_n wall_ro X Y Z]=LSE(wallV);
    
    dotX = points3d(:,1) * wall_n(1);
    dotY = points3d(:,2) * wall_n(2);
    dotZ = points3d(:,3) * wall_n(3);
    distWall = abs(dotX + dotY + dotZ - wall_ro);
    wall_thres = 0.1;
    wallPoints = points3d(distWall < wall_thres,:);
    
    if length(wallPoints) >= 1000
        [wall_best,wall_n_best,wall_ro_best,X_best,Y_best,Z_best,error_best,sample_best,success]=local_ransac_bai(wallPoints,100,1000,0.02,length(wallPoints)/2); 
    else
        success = 0;
    end
    
    if success
        wall_mean = mean(wall_best);
        
        N = wall_n_best';
        N2 = N.'*N;
        wallVnew = wallV*(eye(3)-N2)+repmat(wall_mean*N2, size(wallV,1),1);
        
        roomF = [roomF;[1,2,3;1,2,4;3,4,1] + length(roomV)];
        roomV = [roomV;wallVnew];
    else
        roomF = [roomF;[1,2,3;1,2,4;3,4,1] + length(roomV)];
        roomV = [roomV;wallV];
    end
end
    
wallDepth = render_depth(double(roomV), roomF, imageData);

roomDepth = wallDepth;
roomDepth(roomDepth == 0) = floorDepth(roomDepth == 0);

end