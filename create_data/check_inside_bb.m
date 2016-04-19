function [inside_bb] = check_inside_bb(imageData,points3d)

data = imageData;
objDataSet = data.groundtruth3DBB;

inside_bb = boolean(zeros(length(points3d),1));

for i = 1:length(objDataSet)
    objData = objDataSet(i);    
    [ inside_valid ] = get_points_in_box( points3d, objData );
    inside_bb = inside_bb | inside_valid;
end
end