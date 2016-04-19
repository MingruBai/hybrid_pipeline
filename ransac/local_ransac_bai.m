% Tim Zaman, 2010, TU Delft, MSc:ME:BME:BMD:BR
%
% This local_ransac algorythm uses the 'no' amount of closest variables to
%  the randomly chosen point:
%
% Usage:
% [p_best,n_best,ro_best,X_best,Y_best,Z_best,error_best,sample_best]=local_ransac_tim(p,no,k,t,d)
%
% no smallest number of points required
% k number of iterations
% t threshold used to id a point that fits well
% d number of nearby points required


function [p_best,n_best,ro_best,X_best,Y_best,Z_best,error_best,sample_best,success]=local_ransac_bai(p,no,k,t,d)

p_best = [];
n_best = [];
ro_best = [];
X_best = [];
Y_best = [];
Z_best = [];
error_best = [];
sample_best = [];

disp('ransac');
success=0;

%Initialize variables
iterations=0;
%Until k iterations have occurrec
while iterations < k && success == 0
    clear p_close dist p_new p_in p_out sample_in loc_dist sample_out
    
    %Pick a point
    sample_in(1)=randi(length(p)); %point location
    p_in(1,:)=p(sample_in(1),:); %point value
    
    %Compute all local distances to this point
    loc_dist=sqrt((p_in(1)-p(:,1)).^2+(p_in(2)-p(:,2)).^2+(p_in(3)-p(:,3)).^2);
    
    %Initialize sample out
    sample_out=[1:1:length(p)];
    
    %Exclude the sample_in's
    sample_out=sample_out(sample_out~=sample_in(1)); %remove first
    
    for n=1:no
        
        %Make sure the first sample can not be chosen anymore
        loc_dist(sample_in(n))=inf;
        [~,sample_in(n+1)]=min(loc_dist);     %point location
        p_in(n+1,:)=p(sample_in(n+1),:);        %point value
        
        %Exclude the sample_in's
        sample_out=sample_out(sample_out~=sample_in(n+1)); %remove
        
    end
    
    
    %Fit to that set of n points
    [n_est_in ro_est_in]=LSE(p_in);
    
    p_new=p_in;
    
    %For each data point oustide the sample
    
    sample_out_points_index = [p(sample_out,:) sample_out'];
    
    dotX = sample_out_points_index(:,1) * n_est_in(1);
    dotY = sample_out_points_index(:,2) * n_est_in(2);
    dotZ = sample_out_points_index(:,3) * n_est_in(3);
    dist = abs(dotX + dotY + dotZ - ro_est_in);
    
    p_new_index = sample_out_points_index(dist < t,:);
    p_new = [p_new; p_new_index(:,1:3)];
    sample_in = [sample_in p_new_index(:,4)'];
    
    
    
    %If there are d or more points close to the line
    if length(p_new) > d
        %Refit the line using all these points
        [n_est_new ro_est_new X Y Z]=LSE(p_new);
        
        dotX = p_new(:,1) * n_est_new(1);
        dotY = p_new(:,2) * n_est_new(2);
        dotZ = p_new(:,3) * n_est_new(3);
        dist = abs(dotX + dotY + dotZ - ro_est_new);
        
        %Use the fitting error as error criterion (ive used SAD for ease)
        error(iterations+1)=sum(abs(dist));
    else
        error(iterations+1)=inf;
    end
    
    if length(p_new) > d %made this up myself too
        if iterations >1
            %Use the best fit from this collection
            if error(iterations+1) <= min(error)
                disp(['Took ',num2str(iterations+1),' iterations.']);
                success=1;
                p_best=p_new;
                n_best=n_est_new;
                ro_best=ro_est_new;
                X_best=X;
                Y_best=Y;
                Z_best=Z;
                error_best=error(iterations+1);
                sample_best=sample_in;
            end
        end
    end
    
    iterations=iterations+1;
end


end