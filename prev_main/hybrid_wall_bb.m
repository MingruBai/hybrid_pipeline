%function main_hybrid(ID) vv
addpath(genpath('.'));
load('./Metadata/SUNRGBDMeta_best_Oct19.mat');

for imageId = 1:1;

disp(imageId);

folderPath = ['./results/scene',num2str(imageId)];
createFolderInstr = ['mkdir ',folderPath];
system(createFolderInstr);

%specify scene to recreate:
imageData = SUNRGBDMeta_best_Oct19(imageId);

%readData:
objDataset = imageData.groundtruth3DBB;

[all_obj_points, all_obj_dim, XYZ, inside_bb] = get_obj_points(SUNRGBDMeta_best_Oct19,imageId);
[rgb,points3d,depthInpaint,imsize,XYZ]=read3dPoints(imageData);

points3dvalid = points3d;

points3dvalid(isnan(points3d(:,1)) | inside_bb, 1) = 0;
points3dvalid(isnan(points3d(:,1)) | inside_bb, 2) = 0;
points3dvalid(isnan(points3d(:,1)) | inside_bb, 3) = 0;

Xvalid = points3dvalid(:,1);
Yvalid = points3dvalid(:,2);
Zvalid = points3dvalid(:,3);

XvalidMatrix = reshape(Xvalid, [530,730]);
YvalidMatrix = reshape(Yvalid, [530,730]);
ZvalidMatrix = reshape(Zvalid, [530,730]);

XYZvalid = cat(3,XvalidMatrix,YvalidMatrix,ZvalidMatrix);

[points, faces] = point2mesh(double(XYZvalid));

points = points';
faces = faces';

points(points(:,1) == 0,:) = [];
faces(faces(:,1) == 0,:) = [];


pickList = [];
for i = 1:length(objDataset)
    pickList = [pickList,1];
end

%get paths:
outputPath = ['./output/scene',num2str(imageId)];
all_list = [];
for o=1:length(objDataset)
    temp = dir([outputPath,'/',num2str(o),'_',objDataset(o).classname,'_list.txt']);
    all_list = [all_list;temp];
end

bestModelPath = [];

for i = 1:length(all_list)
    fname = all_list(i).name;
    fpath = [outputPath,'/',fname];
    fid = fopen(fpath,'r');
    file_text=fread(fid, inf, 'uint8=>char')';
    fclose(fid);
    file_lines = regexp(file_text, '\n+', 'split');
    line1 = file_lines{pickList(i)};
    line1list = strsplit(line1);
    bestPath = line1list(1);
    bestModelPath=[bestModelPath;bestPath];
end

allV = points;
allF = faces;

totalPrevV = length(allV);
%create objects:
for i = 1:length(objDataset)
    objId = i;
    objData = objDataset(objId);
    keyword = objData.classname;
    
    bestPath = bestModelPath(i);
    bestPath = bestPath{1};
    
    %same obj use same list of models:
    objname = keyword;
    for objid = 1:length(objDataset)
        if strcmp(objname,objDataset(objid).classname)
            bestPath = bestModelPath(objid);
            bestPath = bestPath{1};
            break;
        end
    end
    
    
    if strcmp(bestPath,'')
        continue;
    end
    
    [vList,fList] = create_obj(objData, ['~/Dropbox/CV/workspace/Yinda/',bestPath]);
    
    allV = [allV;vList];
    fList = fList + totalPrevV;
    allF = [allF;fList];
    totalPrevV = totalPrevV + size(vList,1);
end

write_img('test.png',allV,allF,imageData);
% write_ply([folderPath,'/scene',num2str(imageId),'.ply'],allV,allF,imageData);
% 
% wallData = imageData.gtCorner3D;
% 
% if length(wallData ~= 0)
%     [wallV, wallF] = create_wall(wallData);
% end
% 
% wallDepth = render_depth(wallV, wallF, imageData);
% hybridDepth = render_depth(allV, allF, imageData);
% 
% hybridDepth(hybridDepth == 0) = wallDepth(hybridDepth == 0);
% 
% depthMin = min(hybridDepth(:));
% depthMax = max(hybridDepth(:));
% depthNorm = double(hybridDepth-depthMin)/double(depthMax-depthMin);
% depthNorm (depthNorm == 0) = flintmax;
% 
% [rgb,points3dall, XYZ]=read_3d_pts_general(hybridDepth,imageData.K,size(hybridDepth),imageData.rgbpath);
% points3dall = (imageData.Rtilt*points3dall')';
% points2ply([folderPath,'/scene',num2str(imageId),'_wall.ply'], points3dall');
% 
% imwrite(depthNorm, 'test.png');

end