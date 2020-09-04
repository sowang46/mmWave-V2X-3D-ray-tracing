function writeWIObject(folderName,fileName,...
                       facevert,nvertex,material,header,footer)

ofid=fopen([folderName '/' fileName  '.object'],'w');
fprintf(ofid,'%s',header{:});
nlchar=[char(13) char(10)];
for n=1:length(facevert)
    fprintf(ofid,['begin_<face>' nlchar]);
    fprintf(ofid,'Material %d',material(n));  
    fprintf(ofid,nlchar);
    fprintf(ofid,'nVertices %d',nvertex(n));
    fprintf(ofid,nlchar);
    for m=1:nvertex(n)
        fprintf(ofid,'%5.10f ',facevert{n}(m,1)); %x
        fprintf(ofid,'%5.10f ',facevert{n}(m,2)); %y
        fprintf(ofid,'%5.10f',facevert{n}(m,3));%z
        fprintf(ofid,nlchar);
    end
    fprintf(ofid,'end_<face>');
    fprintf(ofid,nlchar);
end

fprintf(ofid,'%s',footer{:});
fclose(ofid);

end