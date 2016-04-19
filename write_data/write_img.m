function write_img(imagePath, allV, allF,imageData)


disp('Writing scene to img... ');

renderF = [allF allF(:,1)];
K = imageData.K;
P = K*[inv(imageData.Rtilt*[1 0 0;0 0 1;0 1 0]) zeros(3,1)];
img = imread(imageData.depthpath);
imsize = size(img);

result = RenderMex(P, imsize(2), imsize(1), allV', uint32(renderF'-1))';
z_near = 0.3;
depth = z_near./double(1-double(result)/2^32);
depthMin = min(depth(:));
depthMax = max(depth(abs(depth) < 100));

depth = double(depth-depthMin)/double(depthMax-depthMin);

imwrite(depth, imagePath);

end