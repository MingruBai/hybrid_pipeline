function groups = get_group(imageData)
[rgb,points3d,depthInpaint,imsize,XYZ]=read3dPoints_bfx(imageData);

points3dvalid = points3d;

Xvalid = points3dvalid(:,1);
Yvalid = points3dvalid(:,2);
Zvalid = points3dvalid(:,3);

XvalidMatrix = reshape(Xvalid, imsize);
YvalidMatrix = reshape(Yvalid, imsize);
ZvalidMatrix = reshape(Zvalid, imsize);
XYZvalid = cat(3,XvalidMatrix,YvalidMatrix,ZvalidMatrix);
groups = group_points(double(XYZvalid));

end