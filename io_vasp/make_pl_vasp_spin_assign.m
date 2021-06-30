clc; clear;
fid = fopen('OUTCAR','r'); 

%%
fprintf('\n\n%s\n\n','--------------------------- Find last magnetization data')    
fseek(fid,0,'bof');
while ~feof(fid)
    pos = ftell(fid);
    tline = fgetl(fid); disp(tline)
    if(strcmp(tline,' magnetization (x)'))
        posmag = pos;
    end
end

%%
fprintf('\n\n%s\n\n','--------------------------- Count the number of atoms') 
fseek(fid,posmag,'bof');
natom = 0;
tline = '';
while ~strcmp(tline,'--------------------------------------------------')
    tline = fgetl(fid); disp(tline)
    if strcmp(tline,'------------------------------------------')
        while true
            tline = fgetl(fid); disp(tline)
            if strcmp(tline,'--------------------------------------------------'), break, end
            remain = tline;
            [token, remain] = strtok(remain);
            natom = str2num(token);
        end
    end
    if strcmp(tline,'--------------------------------------------------'), break, end
end         
fprintf('\n\n%s%d\n\n','The number of atoms : ',natom);


%%
fprintf('\n\n%s\n\n','--------------------------- Copy the last magnetization data')   
data = zeros(natom,5);
fseek(fid,posmag,'bof');
tline = '';
while ~strcmp(tline,'--------------------------------------------------')
    tline = fgetl(fid); disp(tline)
    if strcmp(tline,'------------------------------------------')
        i = 0;
        while true
            i = i + 1;
            tline = fgetl(fid); disp(tline)
            if strcmp(tline,'--------------------------------------------------'), break, end
            remain = tline;
            for j = 1:5
                [token, remain] = strtok(remain);
                data(i,j) = str2double(token);
            end
        end
    end 
end

fclose(fid);
%%
fid = fopen('vasp_assign_spin.pl','w');
fprintf(fid,'%s\n\n','#!perl');
fprintf(fid,'%s\n','use strict;');
fprintf(fid,'%s\n','use Getopt::Long;');
fprintf(fid,'%s\n\n','use MaterialsScript qw(:all);');


fprintf(fid,'%s\n','my $xsddoc = $Documents{"CONTCAR".".xsd"};');
fprintf(fid,'%s\n\n','my $atoms = $xsddoc->UnitCell->Atoms;');

for i=1:size(data,1)
    fprintf(fid,'%s%d%s%6.3f%s\n','$atoms->Item(',data(i,1)-1,')->Spin=	',data(i,5),';');
end

fclose(fid);
