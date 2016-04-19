%function main_hybrid(ID)
addpath(genpath('.'))
load('./SUNRGBDMeta_best_Oct19.mat');

for imageId = 1:1%(ID-1)*1 + 1: ID*1
    
    if ~any(size(dir(['./output/scene',num2str(imageId),'/*.txt']),1))
        disp(['Skip scene ',num2str(imageId),'.']);
        continue;
    end
    
    disp(imageId);
    
    folderPath = ['./results/scene',num2str(imageId)];
    createFolderInstr = ['mkdir ',folderPath];
    system(createFolderInstr);
    
    %specify scene to recreate:
    imageData = SUNRGBDMeta_best_Oct19(imageId);
    
    %readData:
    objDataset = imageData.groundtruth3DBB;
    
    [all_obj_points, all_obj_dim, XYZ, inside_bb] = get_obj_points(SUNRGBDMeta_best_Oct19,imageId);
  
%     for i = 1:size(XYZ,1)-1
%         disp(i);
%         for j = 1:size(XYZ,2)-1
%             
%             p = [XYZ(i,j,1),XYZ(i,j,2),XYZ(i,j,3)];
%             p = (imageData.Rtilt*p')';
%             XYZ(i,j,:) = p;
%         end
%     end
    
    data = SUNRGBDMeta_best_Oct19(imageId);
    [rgb,points3d,depthInpaint,imsize,XYZ]=read3dPoints(data);
    
    %     valid = single(~isnan(XYZ(:,:,1)));
    %
    %     X = XYZ(:,:,1);
    %     Y = XYZ(:,:,2);
    %     Z = XYZ(:,:,3);
    %
    %     X(~valid) = 0;
    %     Y(~valid) = 0;
    %     Z(~valid) = 0;
    %
    %     XYZcamera = [];
    %     XYZcamera(:,:,1) = X;
    %     XYZcamera(:,:,2) = Y;
    %     XYZcamera(:,:,3) = Z;
    %     XYZcamera(:,:,4) = valid;
    
%     pointsIndex = zeros(size(XYZ,1),size(XYZ,2));
%     points = [];
%     faces = [];
%     curIndex = 1;
%     thres = 0.1;
%     for i = 1:size(XYZ,1)-1
%         disp(i);
%         for j = 1:size(XYZ,2)-1
%             
%             p1 = [XYZ(i,j,1),XYZ(i,j,2),XYZ(i,j,3)];
%             p2 = [XYZ(i+1,j,1),XYZ(i+1,j,2),XYZ(i+1,j,3)];
%             p3 = [XYZ(i+1,j+1,1),XYZ(i+1,j+1,2),XYZ(i+1,j+1,3)];
%             p4 = [XYZ(i,j+1,1),XYZ(i,j+1,2),XYZ(i,j+1,3)];
%             
%             if isnan(p1(1)) || isnan(p2(1)) || isnan(p3(1)) || isnan(p4(1))
%                 continue;
%             end
%             
%             if check_dist(p1,p2,thres) && check_dist(p2,p3,thres) && check_dist(p3,p4,thres) && check_dist(p4,p1,thres)
%                 if pointsIndex(i,j)~=0
%                     i1 = pointsIndex(i,j);
%                 else
%                     pointsIndex(i,j) = curIndex;
%                     curIndex = curIndex + 1;
%                     points = [points;p1];
%                     i1 = pointsIndex(i,j);
%                 end
%                 
%                 if pointsIndex(i+1,j)~=0
%                     i2 = pointsIndex(i+1,j);
%                 else
%                     pointsIndex(i+1,j) = curIndex;
%                     curIndex = curIndex + 1;
%                     points = [points;p2];
%                     i2 = pointsIndex(i+1,j);
%                 end
%                 
%                 if pointsIndex(i+1,j+1)~=0
%                     i3 = pointsIndex(i+1,j+1);
%                 else
%                     pointsIndex(i+1,j+1) = curIndex;
%                     curIndex = curIndex + 1;
%                     points = [points;p3];
%                     i3 = pointsIndex(i+1,j+1);
%                 end
%                 
%                 if pointsIndex(i,j+1)~=0
%                     i4 = pointsIndex(i,j+1);
%                 else
%                     pointsIndex(i,j+1) = curIndex;
%                     curIndex = curIndex + 1;
%                     points = [points;p4];
%                     i4 = pointsIndex(i,j+1);
%                 end
%                 
%                 newf = [i1,i2,i4;i2,i4,i3];
%                 faces = [faces;newf];
%                 
%             end
%             
%         end
%     end
    %
    %     points3dvalid = points3d;
    %     points3dvalid(isnan(points3d(:,1)) | inside_bb,:) = [];
    %     points3dvalid = double(points3dvalid);
    %
    %
    %
    %     DT = delaunayTriangulation(points3dvalid);
    %     CL = DT.ConnectivityList;
    %     points = DT.Points;
    %     thres = 0.1;
    %
    %     faces = [CL(:,1) CL(:,2) CL(:,3)];
    %     faces = [faces; CL(:,1) CL(:,2) CL(:,4)];
    %     faces = [faces; CL(:,2) CL(:,3) CL(:,4)];
    %     faces = [faces; CL(:,1) CL(:,4) CL(:,4)];
    %
    %     invalid1 = thres < ((points(faces(:,1),1) - points(faces(:,2),1)).^2 + (points(faces(:,1),2) - points(faces(:,2),2)).^2 + (points(faces(:,1),3) - points(faces(:,2),3)).^2).^0.5;
    %     invalid2 = thres < ((points(faces(:,1),1) - points(faces(:,3),1)).^2 + (points(faces(:,1),2) - points(faces(:,3),2)).^2 + (points(faces(:,1),3) - points(faces(:,3),3)).^2).^0.5;
    %     invalid3 = thres < ((points(faces(:,2),1) - points(faces(:,3),1)).^2 + (points(faces(:,2),2) - points(faces(:,3),2)).^2 + (points(faces(:,2),3) - points(faces(:,3),3)).^2).^0.5;
    %
    %     invalid = invalid1 | invalid2 | invalid3;
    %
    %     faces(invalid,:) = [];
    %

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
    
    if length(all_list) ~= length(objDataset)
        disp([num2str(imageId),'not equal']);
        continue;
    end
    
    
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
    
    write_img([folderPath,'/scene',num2str(imageId),'.jpeg'],allV,allF,imageData);
    write_ply([folderPath,'/scene',num2str(imageId),'.ply'],allV,allF,imageData);
    
end

