function facevert_trans = translateAlongY(trans_vec,facevert)

for n=1:length(facevert)
    n_vertices = size(facevert{n},1);
    facevert_trans{n} = facevert{n}+repmat(trans_vec,n_vertices,1);
end

end