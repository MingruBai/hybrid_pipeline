function [vList,fList]=create_obj(objData, shapePath)

disp(['Processing ',shapePath,'...']);

shapeOri = [-1,0,0];
objOri = [objData.orientation(1),objData.orientation(2),objData.orientation(3)];
xBasis = [objData.basis(1,1),objData.basis(1,2),objData.basis(1,3)];
yBasis = [objData.basis(2,1),objData.basis(2,2),objData.basis(2,3)];

%get correct dimensions:
if abs(dot(objOri,xBasis)) > abs(dot(objOri,yBasis))
    xDim = objData.coeffs(1);
    yDim = objData.coeffs(2);
else
    xDim = objData.coeffs(2);
    yDim = objData.coeffs(1);
end
zDim = objData.coeffs(3);


vdot = shapeOri(1)*objOri(1)+shapeOri(2)*objOri(2);
vdet = shapeOri(1)*objOri(2)-shapeOri(2)*objOri(1);
theta = atan2(vdet, vdot);
costheta = cos(theta);
sintheta = sin(theta);
rMatrix = [costheta,-sintheta;sintheta,costheta];

%read shape data:

fList = [];
nf = 0;
vList = [];
nv = 0;

fid = fopen(shapePath,'r');
file_text=fread(fid, inf, 'uint8=>char')';
fclose(fid);
file_lines = regexp(file_text, '\n+', 'split');

for i=1:length(file_lines)
    line = file_lines{i};
    list = regexp(line, ' ', 'split');
    if char(list{1}) == 'f'
        nf = nf+1;
        %if(mod(nf,1000)==1), fList(nf+1:nf+1001,1:3)=0; end
        fList(nf,1:3) = [str2double(list{2}),str2double(list{3}),str2double(list{4})];
    end
    
    if char(list{1}) == 'v'
        nv = nv+1;
        %if(mod(nv,1000)==1), vList(nv+1:nv+1001,1:3)=0; end
        vList(nv,1:3) = [str2double(list{2}),str2double(list{4}),str2double(list{3})];
    end
end

%resize:
maxX = 0;
maxY = 0;
maxZ = 0;
for i = 1:length(vList)
    maxX = max(maxX,vList(i,1));
    maxY = max(maxY,vList(i,2));
    maxZ = max(maxZ,vList(i,3));
end

ratioX = xDim/maxX;
ratioY = yDim/maxY;
ratioZ = zDim/maxZ;

ratio = min([ratioX,ratioY]);

for i = 1:length(vList)
    vList(i,1) = shapeOri(1) * vList(i,1) * ratio;
    vList(i,2) = vList(i,2) * ratio;
    vList(i,3) = vList(i,3) * ratioZ;
end

%rotation:
for i = 1:length(vList)
    vect = [vList(i,1);vList(i,2)];
    newVect = rMatrix * vect;
    vList(i,1) = newVect(1,1);
    vList(i,2) = newVect(2,1);
end

%displacement:
for i = 1:length(vList)
    vList(i,1) = vList(i,1) + objData.centroid(1);
    vList(i,2) = vList(i,2) + objData.centroid(2);
    vList(i,3) = vList(i,3) + objData.centroid(3);
end
end

