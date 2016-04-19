function [ok]=check_dist(p1,p2,thres)

    ok = ((p1(1)-p2(1))^2 + (p1(2)-p2(2))^2 + (p1(2)-p2(2))^2)^0.5 < thres;

end