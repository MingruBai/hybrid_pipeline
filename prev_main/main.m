%function main(ID, pickList)

addpath(genpath('.'))
load('./Metadata/SUNRGBDMeta.mat');
load('./Metadata/MapForward.mat');

%imageId = MapForward(ID);
imageId = ID;

if (imageId == 0)
    disp('Image not processed due to low quality.');
    return
end

folderPath = ['./results/scene',num2str(imageId)];
createFolderInstr = ['mkdir ',folderPath];
system(createFolderInstr);

%specify scene to recreate:
imageData = SUNRGBDMeta(imageId);

%readData:
objDataset = imageData.groundtruth3DBB;

%if nargin < 2
    pickList = [];
    for i = 1:length(objDataset)
        pickList = [pickList,1];
    end
%end

if length(pickList) < length(objDataset)
    disp(['Error: There are ',num2str(length(objDataset)),' objects but user only specified ', num2str(length(pickList)),'.']);
    return;
end

%get paths:
outputPath = ['../Yinda_mutual/output/scene',num2str(imageId)];
all_list = dir([outputPath,'/*.txt']);

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

allV = [];
allF = [];

wallData = imageData.gtCorner3D;

if length(wallData ~= 0)
    [wallV, wallF] = create_wall(wallData);
    allV = [allV; wallV];
    allF = [allF; wallF];
end

totalPrevV = length(allV);
%create objects:
for i = 1:length(objDataset)
    objId = i;
    objData = objDataset(objId);
    keyword = objData.classname;
    
    bestPath = bestModelPath(i);
    bestPath = bestPath{1};
    
    if strcmp(bestPath,'')
        continue;
    end
    
    [vList,fList] = create_obj(objData, bestPath);
    
    allV = [allV;vList];
    fList = fList + totalPrevV;
    allF = [allF;fList];
    totalPrevV = totalPrevV + size(vList,1);
end

write_img([folderPath,'/scene',num2str(imageId),'.jpeg'],allV,allF,imageData);
write_obj([folderPath,'/scene',num2str(imageId),'.obj'],allV,allF);
write_off([folderPath,'/scene',num2str(imageId),'.off'],allV,allF);

%end