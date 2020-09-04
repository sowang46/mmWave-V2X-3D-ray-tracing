function moveObj(wiFolder, objectFileName, trans_vec, degree, simuFolder)

[header,footer,material,numvertex,facevert] = read_object(wiFolder, objectFileName);

%Define axis of the object
centroidobj=sum(cell2mat(facevert'))/size(cell2mat(facevert(1,:)'),1);
normalize = [-centroidobj(1), -centroidobj(2), 0];

% trans_vec is the coordinates of your new block
% theta is the angle of the new object

theta = degree/180*pi;
rotMat = [cos(theta) sin(theta) 0; ...
    -sin(theta) cos(theta) 0; ...
    0 0 1];

faceverttrans = rotateAlongZ(rotMat,facevert);
faceverttrans = translateAlongY(trans_vec,faceverttrans);

writeWIObject(simuFolder,convertStringsToChars(objectFileName),faceverttrans, numvertex,material,header,footer);