 

% This script updates the shocks from Jarocinski, Karadi (2020) AEJ:Macro
clear all, close all 
 
MainPath = "Z:/临时备份/Research/paper/货币政策/Data/CN_MP" 
 
cd(MainPath)   

pathin = "Z:/临时备份/Research/paper/货币政策/Data/";
pathout = "Z:/临时备份/Research/paper/货币政策/Data/";

% Interest rate surprises to extract pc from, stock index
irnames = "dIRS";
stockname = "SH";

% Load the high-frequency surprises dataset
tab = readtable(pathin + "CN_MP_use.csv");

% Select the sample
isample = year(tab.date) > 1989; % until 1989 there are many missing obs
tab = tab(isample,:);
fprintf('Data from %s to %s, T=%d\n', tab{1,'date'}, tab{end,'date'}, size(tab,1))

% Compute the 1st principal component
pc1 = mypc(tab, irnames, "dIRS");
tab.pc1 = round(pc1,8);

% keep only the variables we need
tab = tab(:,["date","pc1",stockname]); 

% Compute the poor man and median shocks
M = tab{:,["pc1",stockname]};
% poor man's shocks
U_pm = [M(:,1).*(prod(M,2)<0) M(:,1).*(prod(M,2)>=0)];
% median shocks
U_median = signrestr_median(M);
% replace missing shocks with zeros
U_median(isnan(U_median)) = 0;

% Save high-frequency shocks
shocks_names = ["MP_pm","CBI_pm","MP_median","CBI_median"];
shocks_table = array2table(round([U_pm U_median],8), 'VariableNames', shocks_names);
tab = [tab shocks_table];
tab.date.Format = "uuuu-MM-dd HH:mm";
filename_t = "shocks_CN_t.csv";
writetable(tab, pathout + filename_t);

% Aggregate to monthly
mtab = table_d2m2q(tab);
mtab.Properties.VariableNames(3:4) = mtab.Properties.VariableNames(3:4) + "_hf";
writetable(mtab, pathout + strrep(filename_t, "_t.csv", "_m.csv"));