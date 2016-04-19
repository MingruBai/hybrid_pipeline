function [vList, fList, wallVisData] = create_wall_vis(imageData)

wallData = imageData.gtCorner3D;

vList = [];
fList = [];
wallVisData = [];

%If no wall data:
if length(wallData) == 0
    return;
end

n = size(wallData,2);

for i = 1:n
    tempV = wallData(1:3,i)';
    vList = [vList;tempV];
end


vList2D = vList(1:n/2,1:2);
%Define edges:
C = [n/2,1];
for i = 1:n/2-1
    C = [C;i,i+1];
end

%get floors:
d1 = delaunayTriangulation(vList2D,C);
tri1all = d1.ConnectivityList;
tri1 = [];
interiorStatus = isInterior(d1);
for i = 1:size(tri1all,1)
    if interiorStatus(i)
        tri1 = [tri1;tri1all(i,:)];
    end
end
tri2 = tri1 + n/2;

if wallData(3,1) > wallData(3,size(wallData,2))
    ceiling = tri1;
    floor = tri2;
else
    floor = tri1;
    ceiling = tri2;
end

%rendering parameters:
K = imageData.K;
P = K*[inv(imageData.Rtilt*[1 0 0;0 0 1;0 1 0]) zeros(3,1)];
img = imread(imageData.depthpath);
imsize = size(img);

%Check ceiling visible:
renderF = [ceiling ceiling(:,1)];
result = RenderMex(P, imsize(2), imsize(1), vList', uint32(renderF'-1))';
z_near = 0.3;
depth = z_near./double(1-double(result)/2^32);
depthMin = min(depth(:));
depthMax = max(depth(abs(depth) < 100));
depth(depth>10) = 0;
if sum(depth(:)) > 0
    fList = [fList;ceiling];
    wallVisData.vis_ceiling = 1;
else
    wallVisData.vis_ceiling = 0;
end

%Check floor visible:
renderF = [floor floor(:,1)];
result = RenderMex(P, imsize(2), imsize(1), vList', uint32(renderF'-1))';
z_near = 0.3;
depth = z_near./double(1-double(result)/2^32);
depthMin = min(depth(:));
depthMax = max(depth(abs(depth) < 100));
depth(depth>10) = 0;
if sum(depth(:)) > 0
    fList = [fList;floor];
    wallVisData.vis_floor = 1;
else
    wallVisData.vis_floor = 0;
end

%get vertical walls:
wallList = [];
for i = 2:n/2
    f1 = [i-1, i, i-1+n/2];
    f2 = [i, i+n/2, i-1+n/2];
    wallList = [wallList;f1;f2];
end
fend1 = [1,n/2+1,n];
fend2 = [1,n,n/2];
wallList = [wallList;fend1;fend2];

%Check which vertical walls are visible:
wallVisData.vis_wall = [];
for i = 1:size(wallList,1)/2 
    fWall = wallList(i*2-1:i*2,:);
    renderF = [fWall fWall(:,1)];
    
    result = RenderMex(P, imsize(2), imsize(1), vList', uint32(renderF'-1))';
    z_near = 0.3;
    depth = z_near./double(1-double(result)/2^32);
    depthMin = min(depth(:));
    depthMax = max(depth(abs(depth) < 100));
    depth(depth>10) = 0;

    if sum(depth(:)) > 0
        fList = [fList;fWall];
        wallVisData.vis_wall = [wallVisData.vis_wall;1];
    else
        wallVisData.vis_wall = [wallVisData.vis_wall;0];
    end
end

 %write_img('test.png', vList, fList,imageData);
 %write_obj('test.obj', vList, fList);


end