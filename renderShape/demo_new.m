% load('SUNRGBDMetaRefine.mat');
data_id = 9;
data = SUNRGBDMeta(data_id);

obj_filename = sprintf('./objFilterTool/output/scene%d/scene.obj',data_id);
depth = obj2im(obj_filename, data);
figure; imshow(depth,[]);

[ points3d, points2d ] = depth2points3d( depth, data, [21 168 530 530]);
figure;
vis_point_cloud(points3d);
%% debug code
% K = data.K;
% P = K*[inv(data.Rtilt*[1 0 0;0 0 1;0 1 0]) zeros(3,1)];
% [rgb,points3d,depthInpaint,imsize]=read3dPoints(data);
% 
% [obj] = objLoader(sprintf('./objFilterTool/output/scene%d/scene.obj',data_id));
% % Ryzswi = [1, 0, 0; 0, 0, 1; 0, 1, 0];
% % obj.vmat = Ryzswi * obj.vmat;
% result = RenderMex(P, imsize(2), imsize(1), obj.vmat, uint32(obj.fmat-1))';
% 
% z_near = 0.3;
% depth = z_near./(1-double(result)/2^32);
% % imagesc(depth)
% % axis equal
% % axis tight
% % colorbar
% figure; imshow(depth, [0 5]);
