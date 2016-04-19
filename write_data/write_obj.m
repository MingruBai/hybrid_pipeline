function write_obj(objPath, allV, allF)
createFileInstr = ['touch ',objPath];
system(createFileInstr);

disp('Writing scene to obj... ');
fp = fopen(objPath,'w');

for i = 1:length(allV)
    toWrite = ['v ',num2str(allV(i,1)),' ',num2str(allV(i,2)),' ',num2str(allV(i,3)),'\n'];
    fprintf(fp,toWrite);
end

for i = 1:length(allF)
    toWrite = ['f ',num2str(allF(i,1)),' ',num2str(allF(i,2)),' ',num2str(allF(i,3)),'\n'];
    fprintf(fp,toWrite);
end

fclose(fp);
end

