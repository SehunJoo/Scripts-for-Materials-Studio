clc; clear;

%% Read OUTCAR

fid = fopen('OUTCAR','r'); 

fprintf('\n\n%s\n\n','--------------------------- Read OUTCAR')    
fseek(fid,0,'bof');
while ~feof(fid)
    tline = fgetl(fid); disp(tline)
    if strncmp(tline,'   ions per type =', 18)
        ntype=0;
        remain = tline;
        [token, remain] = strtok(remain);
        [token, remain] = strtok(remain);
        [token, remain] = strtok(remain);
        [token, remain] = strtok(remain);
        while(1)
            [token, remain] = strtok(remain);
            ntype= ntype+1
            if strcmp(remain,'')
                break
            end
        end
        break

    end
end

natom = zeros(ntype,1);
zval = zeros(ntype,1);

fseek(fid,0,'bof');
while ~feof(fid)
    tline = fgetl(fid); disp(tline)
    if strncmp(tline,'   ions per type =', 18)
        i=0;
        remain = tline;
        [token, remain] = strtok(remain);
        [token, remain] = strtok(remain);
        [token, remain] = strtok(remain);
        [token, remain] = strtok(remain);
        while true
            i = i+1;
            [token, remain] = strtok(remain);
            natom(i,1) = str2num(token)
            if strcmp(remain,'')
                break
            end
        end
        break

    end
end

fseek(fid,0,'bof');
while ~feof(fid)
    tline = fgetl(fid); disp(tline)
    if strncmp(tline,'  Ionic Valenz', 14)
        tline = fgetl(fid); disp(tline)
        i=0;
        remain = tline;
        [token, remain] = strtok(remain);
        [token, remain] = strtok(remain);
        while true
            i = i+1;
            [token, remain] = strtok(remain);
            zval(i,1) = str2double(token)
            if strcmp(remain,''), break, end
        end
        break

    end
end

fclose(fid);
%% Read ACF.dat

fid = fopen('ACF.dat','r'); 

fprintf('\n\n%s\n\n','--------------------------- Read ACF.dat')    
data = zeros(sum(natom),8);

fseek(fid,0,'bof');
while ~feof(fid)
    tline = fgetl(fid); disp(tline)
    if strcmp(tline,' --------------------------------------------------------------------------------')
        i = 0;
        while true
            i = i + 1;
            tline = fgetl(fid); disp(tline)
            if strcmp(tline,' --------------------------------------------------------------------------------'), break, end
            remain = tline;
            for j = 1:7
                [token, remain] = strtok(remain);
                data(i,j) = str2double(token);
            end
        end
    end 
end

fclose(fid);
%% Calculate Charge
j = 1;
ctr = 1;
for i = 1:sum(natom)
    data(i,8) = zval(j)-data(i,5);
    if ctr == natom(j)
        i
        ctr = 1;
        j = j+1;
    else
        ctr = ctr+1;
    end
end

%%
fid = fopen('vasp_assign_charge.pl','w');

fprintf(fid,'%s\n\n','#!perl');
fprintf(fid,'%s\n','use strict;');
fprintf(fid,'%s\n','use Getopt::Long;');
fprintf(fid,'%s\n\n','use MaterialsScript qw(:all);');


fprintf(fid,'%s\n','my $xsddoc = $Documents{"CONTCAR".".xsd"};');
fprintf(fid,'%s\n\n','my $atoms = $xsddoc->UnitCell->Atoms;');

for i=1:size(data,1)
    fprintf(fid,'%s%d%s%6.3f%s\n','$atoms->Item(',data(i,1)-1,')->Charge=	',data(i,8),';');
end

fclose(fid);
