function [ obj ] = objLoader( fname )
%OBJLOADER Summary of this function goes here
%   Detailed explanation goes here
obj.vmat = zeros(3,0);
obj.fmat = zeros(4,0);
v_count = 0;
f_count = 0;

fp = fopen(fname,'r');
while ~feof(fp)
    l = fgetl(fp);
    if strcmp(l(1), 'v')
        v_count = v_count + 1;
        obj.vmat(:,v_count) = str2num(l(3:end))';
    elseif strcmp(l(1), 'f')
        v_ind = str2num(l(3:end))';       
        if length(v_ind)==3
            f_count = f_count + 1;
            obj.fmat(:,f_count) = [v_ind; v_ind(1)];
        elseif length(v_ind)==4
            f_count = f_count + 1;
            obj.fmat(:,f_count) = v_ind([1 2 4 1]);
            f_count = f_count + 1;
            obj.fmat(:,f_count) = v_ind([2 4 3 2]);
        else
            fprintf('Unsupported number of vertices!\n');
        end
    else
        fprintf('Prefix Error!\n');
        return;
    end
end
fclose(fp);
obj.fmat = obj.fmat - 1;

end

