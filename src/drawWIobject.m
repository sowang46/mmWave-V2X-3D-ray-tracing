function drawWIobject(h,facevert,p1,p2,col,alphaval)
%Draws the object represented by cell facevert which has all the face
%vertices
%p1,p2 represent the axis of the object
%h is the figure handle

figure(h);
%Plot the surface 
for n=1:length(facevert)
    fill3(facevert{n}(:,1),facevert{n}(:,2),facevert{n}(:,3),col);
end

%Plot the axis
plot3(p1(1),p1(2),p1(3),'co');
plot3(p2(1),p2(2),p2(3),'co');

quiver3(p1(1),p1(2),p1(3), ...
    p2(1)-p1(1),p2(2)-p1(2),p2(3)-p1(3),2,'linewidth',2);
alpha(alphaval);

end