function facevert_trans = rotateAlongZ(rotMat,facevert)

for n=1:length(facevert)
    n_vertices = size(facevert{n},1);
    facevert_trans{n} = facevert{n}*rotMat;
end

end