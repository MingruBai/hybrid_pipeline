function [vList, fList] = create_wall(wallData)

disp('Creating wall...');

vList = [];
fList = [];

n = length(wallData);

for i = 1:n
    tempV = wallData(1:3,i)';
    vList = [vList;tempV];
end

vList2D = vList(1:n/2,1:2);
tri1 = delaunayn(vList2D);
tri2 = tri1 + n/2;

fList = [tri1;tri2];
%write vertical walls:
for i = 2:n/2
    f1 = [i-1, i, i-1+n/2];
    f2 = [i, i+n/2, i-1+n/2];
    fList = [fList;f1;f2];
end

end