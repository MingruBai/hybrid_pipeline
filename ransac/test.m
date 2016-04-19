%combine the four dataset-planes we have made into one
p_tot=points3dvalid;
 
no=100;%smallest number of points required
k=5;%number of iterations
t=0.1;%threshold used to id a point that fits well
d=1000;%number of nearby points required
 
%Initialize samples to pick from
p_tot( p_tot(:,1) == 0,:) = []; 



figure
plot3(p_tot(:,1,1),p_tot(:,2,1),p_tot(:,3,1),'.r')
hold on; grid on
tic;

[p_best,n_best,ro_best,X_best,Y_best,Z_best,error_best,sample_best]=local_ransac_tim(p_tot,no,k,t,d);
toc

plot3(p_best(:,1),p_best(:,2),p_best(:,3),'ok')
mesh(X_best,Y_best,Z_best);colormap([.8 .8 .8])

p_tot = setdiff(p_tot,p_best,'rows');
