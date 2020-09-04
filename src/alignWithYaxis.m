function [vr,thetaz,thetax,Rz,Rx]=alignWithYaxis(v)
%Rotate vector V such that it aligns with the Y axis
%First rotate V about z- axis so that it lands on YZ plane
%and then rotate that vector about x-axis to land on the Y-axis

%thetaz: angle of the vector v to the YZ plane
%thetax: angle of the projection of the vector with the y-axis

%Rz: rotation matrix to rotate the vector on the YZ plane
%Rx: rotation matrix to rotate vector from YZ plane on the Y axis

%vr=Rx*Rz*v;

%Since Rx and Rz are orthogonal matrices Rx'=inv(Rx) and Rz'=inv(Rz)
%We can get back v from vr by v=Rz'*Rx'*vr
v=v(:);

%Find the angle of the vector v with yz plane for rotation
vx=v(1);vy=v(2);vz=v(3);
lenxy=sqrt(vx^2+vy^2);
lenxyz=sqrt(vx^2+vy^2+vz^2);

thetaz=-sign(vx)*acos(vy/lenxy);
thetax=sign(vz)*acos(lenxy/lenxyz);

%Create rotation matrix
%Rotation matrix to rotate the vector v about z-axis onto the Y-Z plane
Rz= [cos(-thetaz) -sin(-thetaz) 0;sin(-thetaz) cos(-thetaz) 0;0 0 1];

%Rotation matrix to rotate the vector v about x-axis onto the Y axis
Rx= [1 0 0;0 cos(-thetax) -sin(-thetax);0 sin(-thetax) cos(-thetax)];

%Rotate the vector
vr=Rx*Rz*v;


end