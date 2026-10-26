% Specify the source directory
sourceDir = 'F:\Experiments\2022\Behavior_Probability\head_fixed\data\M3_PC_tetrodes';

% Specify the target directory
targetDir = 'E:\Experiments\2022\head_fixed\data\M3_PC_tetrodes';

% File extensions to copy
fileExtensions = {'*.txt', '*.DAT', '*.csv', '*.ntt', '*.nde', '*.nev', '*.mat', '*.docx', '*.tif', '*.xlsx', '*.jpg', '*.pptx'};

% Loop through each file extension
for extIdx = 1:length(fileExtensions)
    % Get a list of all files with the current extension in the source directory and its subfolders
    files = dir(fullfile(sourceDir, '**', fileExtensions{extIdx}));
    
    % Loop over the list and copy each file to the corresponding target subfolder
    for i = 1:length(files)
        % Get the full path of the source file
        sourceFile = fullfile(files(i).folder, files(i).name);
        
        % Determine the relative path of the file within the source directory
        relativePath = strrep(files(i).folder, sourceDir, '');
        
        % Define the destination folder, preserving the source directory structure
        destFolder = fullfile(targetDir, relativePath);
        
        % Create the destination folder if it doesn't exist
        if ~exist(destFolder, 'dir')
            mkdir(destFolder);
        end
        
        % Define the destination file path
        destFile = fullfile(destFolder, files(i).name);
        
        % Copy the file
        copyfile(sourceFile, destFile);
        
        % Display the file that was copied
        fprintf('Copied: %s to %s\n', sourceFile, destFile);
    end
end
%%
% Specific files to copy
specificFiles = {'CSC33_RESPIRATION.ncs', 'CSC34_LICK.ncs'};
% Loop through each specific file to copy
for fileIdx = 1:length(specificFiles)
    % Get a list of the specific file in the source directory and its subfolders
    specificFile = dir(fullfile(sourceDir, '**', specificFiles{fileIdx}));
    
    % Loop over the list and copy each specific file to the corresponding target subfolder
    for i = 1:length(specificFile)
        % Get the full path of the source file
        sourceFile = fullfile(specificFile(i).folder, specificFile(i).name);
        
        % Determine the relative path of the file within the source directory
        relativePath = strrep(specificFile(i).folder, sourceDir, '');
        
        % Define the destination folder, preserving the source directory structure
        destFolder = fullfile(targetDir, relativePath);
        
        % Create the destination folder if it doesn't exist
        if ~exist(destFolder, 'dir')
            mkdir(destFolder);
        end
        
        % Define the destination file path
        destFile = fullfile(destFolder, specificFile(i).name);
        
        % Copy the file
        copyfile(sourceFile, destFile);
        
        % Display the file that was copied
        fprintf('Copied: %s to %s\n', sourceFile, destFile);
    end
end

fprintf('All specified files, including CSC33_RESPIRATION.ncs and CSC34_LICK.ncs, have been copied successfully, preserving the folder structure.\n');
