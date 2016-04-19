function write_off(offPath, allV, allF)
createFileInstr = ['touch ',offPath];
system(createFileInstr);

disp('Writing scene to off... ');
fp = fopen(offPath,'w');

totalV = length(allV);
totalF = length(allF);

fprintf(fp,'OFF\n');
fprintf(fp,[num2str(totalV),' ',num2str(totalF),' 0\n',]);

for i = 1:length(allV)
    toWrite = [num2str(allV(i,1)),' ',num2str(allV(i,2)),' ',num2str(allV(i,3)),'\n'];
    fprintf(fp,toWrite);
end

for i = 1:length(allF)
    toWrite = ['3 ',num2str(allF(i,1)),' ',num2str(allF(i,2)),' ',num2str(allF(i,3)),'\n'];
    fprintf(fp,toWrite);
end

fclose(fp);
end

