function [all_obj_points, all_obj_dim, XYZ, inside_bb] = get_obj_points_bfx(SUNRGBDMeta,imageId,inputCateList)

all_obj_points = {};
all_obj_dim = {};

data = SUNRGBDMeta(imageId);
[rgb,points3d,depthInpaint,imsize,XYZ]=read3dPoints_bfx(data);
objDataSet = data.groundtruth3DBB;

inside_bb = boolean(zeros(length(points3d),1));

for i = 1:length(objDataSet)
    objData = objDataSet(i);
    objCentroid  = objData.centroid;
    objCoeffs = objData.coeffs;
    
    [ inside_valid ] = get_points_in_box( points3d, objData );
    if sum(ismember(inputCateList,objData.classname))
        inside_bb = inside_bb | inside_valid;
    end
    objPoints3D = points3d(inside_valid,:);
    all_obj_points{end+1} = objPoints3D;
    
    corners = get_corners_of_bb3d(objData);
    rectx = double(corners(1:4,1));
    recty = double(corners(1:4,2));
    zLo = objCentroid(3) - objCoeffs(3);
    zHi = objCentroid(3) + objCoeffs(3);
    
    obj_dim = [max(rectx),min(rectx),max(recty),min(recty),zHi,zLo];
    all_obj_dim{end + 1} = obj_dim;
end
end