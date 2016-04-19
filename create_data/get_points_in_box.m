function [ inside_valid ] = get_points_in_box( points3d, objData )
%GET_POINTS_IN_BOX Summary of this function goes here
%   Detailed explanation goes here
objCentroid  = objData.centroid;
objCoeffs = objData.coeffs;
objBasis = objData.basis;

points_vec = [points3d(:,1)-objCentroid(1) points3d(:,2)-objCentroid(2) points3d(:,3)-objCentroid(3)];
dist = abs(points_vec * objBasis');
inside_valid = dist(:,1)<=objCoeffs(1) & dist(:,2)<=objCoeffs(2) & dist(:,3)<=objCoeffs(3);

end

