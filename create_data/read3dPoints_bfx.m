function [rgb,points3d,depthInpaint,imsize,XYZ]=read3dPoints_bfx(data)
         depthVis = imread(strrep(data.depthpath,'/depth/','/depth_bfx/'));
         imsize = size(depthVis);
         depthInpaint = bitor(bitshift(depthVis,-3), bitshift(depthVis,16-3));
         depthInpaint = single(depthInpaint)/1000; 
         depthInpaint(depthInpaint >8)=8;
         [rgb,points3d, XYZ]=read_3d_pts_general(depthInpaint,data.K,size(depthInpaint),data.rgbpath);
         points3d = (data.Rtilt*points3d')';
end