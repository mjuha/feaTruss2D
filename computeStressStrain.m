function computeStressStrain

global elements u nel coordinates stress strain MAT

stress = zeros(nel,1);
strain = zeros(nel,1);

ue = zeros(4,1);
for i=1:nel
    xe = coordinates(elements(i,2:3),1:2);
    de = u(:,elements(i,2:3));
    E = MAT(elements(i,1),1);
    %
    x1 = xe(1,1);
    x2 = xe(2,1);
    %
    y1 = xe(1,2);
    y2 = xe(2,2);
    %
    le = sqrt( (x2-x1)^2 + (y2-y1)^2 );
    l = (x2 - x1)/le;
    m = (y2-y1)/le;
    for j=1:2 % loop over local nodes
        ue(2*j-1) = de(1,j);
        ue(2*j) = de(2,j);
    end
    str = (1/le)*[-l -m l m]*ue;
    sigma = E*str;
    
    stress(i) = sigma;
    strain(i) = str;
    
end

end