function [allMiceData] = concateMiceData(miceNumbers)
M1 = [];M2 = [];M3 = [];M4 = [];M5 = [];M6 = [];M7 = [];
allMiceData = [];
%%
macPath = '/Volumes/Tal`s disk/Experiments/2022/Behavior_Probability/head_fixed/data/';
windowsPath = 'E:\Tal\Experiments\2022\Behavior_Probability\head_fixed\data\';
%% M1
if ~isempty(find(miceNumbers == 1))
    if ismac
        cd([macPath 'M1_PC_tetrodes'])
    else
        cd([windowsPath 'M1_PC_tetrodes'])
    end
    M1 = load('allRecs_M1_PC_tetrodes');
    allMiceData = [allMiceData M1];
    
end
%% M2
if ~isempty(find(miceNumbers == 2))
    if ismac
        cd([macPath 'M2_PC_tetrodes'])
    else
        cd([windowsPath 'M2_PC_tetrodes'])
    end
    M2 = load('allRecs_M2_PC_tetrodes');
    allMiceData = [allMiceData M2];
end
%% M3
if ~isempty(find(miceNumbers == 3))
    if ismac
        cd([macPath 'M3_PC_tetrodes'])
    else
        cd([windowsPath 'M3_PC_tetrodes'])
    end
    M3 = load('allRecs_M3_PC_tetrodes');
    allMiceData = [allMiceData M3];
    
end

%% M4
if ~isempty(find(miceNumbers == 4))
    if ismac
        cd([macPath 'M4_h4dmGi_OFC'])
    else
        cd([windowsPath 'M4_h4dmGi_OFC'])
    end

    M4 = load('allRecs_M4_h4dmGi_OFC');
    allMiceData = [allMiceData M4];
    
end

%% M5
if ~isempty(find(miceNumbers == 5))
    if ismac
        cd([macPath 'M5_PC_tetrodes'])
    else
        cd([windowsPath 'M5_PC_tetrodes'])
    end
    M5 = load('allRecs_M5_PC_tetrodes');
    allMiceData = [allMiceData M5];
    
end
%% M7
if ~isempty(find(miceNumbers == 7))
    if ismac
        cd([macPath 'M7_PC_tetrodes'])
    else
        cd([windowsPath 'M7_PC_tetrodes'])
    end
    M7 = load('allRecs_M7_PC_tetrodes');
    allMiceData = [allMiceData M7];
    
end
%% M9
if ~isempty(find(miceNumbers == 9))
    if ismac
        cd([macPath 'M9_h4dmGi_OFC_PC_tetrodes'])
    else
        cd([windowsPath 'M9_h4dmGi_OFC_PC_tetrodes'])
    end

    M9 = load('allRecs_M9_h4dmGi_OFC_PC_tetrodes');
    allMiceData = [allMiceData M9];
    
end
%% M10
if ~isempty(find(miceNumbers == 10))
    if ismac
        cd([macPath 'M10_h4dmGi_OFC'])
    else
        cd([windowsPath 'M10_h4dmGi_OFC'])
    end

    M10 = load('allRecs_M10_h4dmGi_OFC');
    allMiceData = [allMiceData M10];
    
end
%% M11
if ~isempty(find(miceNumbers == 11))
    if ismac
        cd([macPath 'M11_h4dmGi_OFC'])
    else
        cd([windowsPath 'M11_h4dmGi_OFC'])
    end

    M11 = load('allRecs_M11_h4dmGi_OFC');
    allMiceData = [allMiceData M11];
    
end
%% M12
if ~isempty(find(miceNumbers == 12))
    if ismac
        cd([macPath 'M12_behavior_WT'])
    else
        cd([windowsPath 'M12_behavior_WT'])
    end

    M12 = load('allRecs_M12_behavior_WT');
    allMiceData = [allMiceData M12];
    
end
%% M13
if ~isempty(find(miceNumbers == 13))
    if ismac
        cd([macPath 'M13_PC_tetrodes'])
    else
        cd([windowsPath 'M13_PC_tetrodes'])
    end

    M13 = load('allRecs_M13_PC_tetrodes');
    allMiceData = [allMiceData M13];
    
end
%% M14
if ~isempty(find(miceNumbers == 14))
    if ismac
        cd([macPath 'M14_h4dmGi_OFC_PC_tetrodes'])
    else
        cd([windowsPath 'M14_h4dmGi_OFC_PC_tetrodes'])
    end

    M14 = load('allRecs_M14_h4dmGi_OFC_PC_tetrodes');
    allMiceData = [allMiceData M14];
    
end
%% M15
if ~isempty(find(miceNumbers == 15))
    if ismac
        cd([macPath 'M15_h4dmGi_OFC'])
    else
        cd([windowsPath 'M15_h4dmGi_OFC'])
    end

    M15 = load('allRecs_M15_h4dmGi_OFC');
    allMiceData = [allMiceData M15];
    
end

%% M16
if ~isempty(find(miceNumbers == 16))
    if ismac
        cd([macPath 'M16_h4dmGi_OFC'])
    else
        cd([windowsPath 'M16_h4dmGi_OFC'])
    end

    M16 = load('allRecs_M16_h4dmGi_OFC');
    allMiceData = [allMiceData M16];
    
end
%% M17
if ~isempty(find(miceNumbers == 17))
    if ismac
        cd([macPath 'M17_PC_tetrodes'])
    else
        cd([windowsPath 'M17_PC_tetrodes'])
    end

    M17 = load('allRecs_M17_PC_tetrodes');
    allMiceData = [allMiceData M17];
    
end
%% M18
if ~isempty(find(miceNumbers == 18))
    if ismac
        cd([macPath 'M18_PC_tetrodes'])
    else
        cd([windowsPath 'M18_PC_tetrodes'])
    end

    M18 = load('allRecs_M18_PC_tetrodes');
    allMiceData = [allMiceData M18];
    
end

%% M20
if ~isempty(find(miceNumbers == 20))
    if ismac
        cd([macPath 'M20_PC_tetrodes'])
    else
        cd([windowsPath 'M20_PC_tetrodes'])
    end

    M20 = load('allRecs_M20_PC_tetrodes_OFC');
    allMiceData = [allMiceData M20];
    
end

%% M23
if ~isempty(find(miceNumbers == 23))
    if ismac
        cd([macPath 'M23_h4dmGi_OFC'])
    else
        cd([windowsPath 'M23_h4dmGi_OFC'])
    end

    M23 = load('allRecs_M23_h4dmGi_OFC');
    allMiceData = [allMiceData M23];
    
end
%% M24
if ~isempty(find(miceNumbers == 24))
    if ismac
        cd([macPath 'M24_h4dmGi_OFC'])
    else
        cd([windowsPath 'M24_h4dmGi_OFC'])
    end

    M24 = load('allRecs_M24_h4dmGi_OFC');
    allMiceData = [allMiceData M24];
    
end

%% M26 - OFC retro
if ~isempty(find(miceNumbers == 26))
    if ismac
        cd([macPath 'M26_hM4Di_retro'])
    else
        cd([windowsPath 'M26_hM4Di_retro'])
    end

    M26 = load('allRecs_M26_hM4Di_retro');
    allMiceData = [allMiceData M26];
    
end