%function main(ID, pickList)

addpath(genpath('.'))
load('./SUNRGBDMeta_best_Oct19.mat');

%imageId = MapForward(ID);
for imageId = 1:10
    
    if (imageId == 0)
        disp('Image not processed due to low quality.');
        return
    end
    
    folderPath = ['./results/scene',num2str(imageId)];
    createFolderInstr = ['mkdir ',folderPath];
    system(createFolderInstr);
    
    %specify scene to recreate:
    imageData = SUNRGBDMeta_best_Oct19(imageId);
    
    %readData:
    objDataset = imageData.groundtruth3DBB;
    
    [all_obj_points, all_obj_dim, XYZ, inside_bb] = get_obj_points(SUNRGBDMeta_best_Oct19,imageId);
    
    data = SUNRGBDMeta_best_Oct19(imageId);
    [rgb,points3d,depthInpaint,imsize,XYZ]=read3dPoints(data);
    
    
    points3dvalid = points3d;
    points3dvalid(isnan(points3d(:,1)) | inside_bb,:) = [];
    points3dvalid = double(points3dvalid);
    
    
    
    DT = delaunayTriangulation(points3dvalid);
    CL = DT.ConnectivityList;
    points = DT.Points;
    thres = 0.1;
    
    faces = [CL(:,1) CL(:,2) CL(:,3)];
    faces = [faces; CL(:,1) CL(:,2) CL(:,4)];
    faces = [faces; CL(:,2) CL(:,3) CL(:,4)];
    faces = [faces; CL(:,1) CL(:,4) CL(:,4)];
    
    invalid1 = thres < ((points(faces(:,1),1) - points(faces(:,2),1)).^2 + (points(faces(:,1),2) - points(faces(:,2),2)).^2 + (points(faces(:,1),3) - points(faces(:,2),3)).^2).^0.5;
    invalid2 = thres < ((points(faces(:,1),1) - points(faces(:,3),1)).^2 + (points(faces(:,1),2) - points(faces(:,3),2)).^2 + (points(faces(:,1),3) - points(faces(:,3),3)).^2).^0.5;
    invalid3 = thres < ((points(faces(:,2),1) - points(faces(:,3),1)).^2 + (points(faces(:,2),2) - points(faces(:,3),2)).^2 + (points(faces(:,2),3) - points(faces(:,3),3)).^2).^0.5;
    
    invalid = invalid1 | invalid2 | invalid3;
    
    faces(invalid,:) = [];
    
    
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
    outputPath = ['./output/scene',num2str(imageId)];
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
    
    %write_img([folderPath,'/scene',num2str(imageId),'.jpeg'],allV,allF,imageData);
    write_ply([folderPath,'/scene',num2str(imageId),'.ply'],allV,allF,imageData);
    
    %points2ply([folderPath,'/scene',num2str(imageId),'.ply'], allV');
    %write_obj([folderPath,'/scene',num2str(imageId),'.obj'],allV,allF);
    %write_off([folderPath,'/scene',num2str(imageId),'.off'],allV,allF);
end
%end