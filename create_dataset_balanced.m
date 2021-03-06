% Constants
instancesPerClass = 1500;
validationPercentage = 1/3;
maxInstancesPerFolder = 300;
newDatasetDir = ['dataset_4500_1500_2'];
setSubDir = 'train';

% Sentiment Scores
anpDir =  'D:/DLSU/Masters/Term 2/CSC930M/Final Project/project_files/final_anps.txt';
sentimentScores = readSentimentScores(anpDir);

% Data 
dataDir  = 'D:/DLSU/Masters/Term 2/CSC930M/Final Project/project_files/resized227';

anpFolders = dir(dataDir);
anpFolders = anpFolders(3:end); % ignore folder /. and /..

% Randomize order in which to process the folders
randomizedAnpFolders = anpFolders(randperm(length(anpFolders)));

amountAdded = zeros(1,3); % negative, neutral, and positive in order
actualCount = 0;
mode = 1; % 1 for training, 2 for validation
for i=1:length(randomizedAnpFolders)
    
   % If all classes have target number of images, then break.
   if amountAdded >= instancesPerClass
       if mode == 1 % switch to creation of validation set
           mode = 2;
           amountAdded = zeros(1,3);
           instancesPerClass = instancesPerClass * validationPercentage;
           setSubDir = 'test';
       else
           break; % done with validation set creation
       end
       
   end
    
   currAnpFolder = randomizedAnpFolders(i);
   try
       currAnpClass = getSentimentClass(sentimentScores(currAnpFolder.name));
   catch exception
       continue; % Skip the folder if there's no available score for it
   end
   
   disp(['Processing: ' currAnpFolder.name '(' num2str(currAnpClass) ')']);
   % Skip this folder if we've reached the target amount of images for the
   % class
   if amountAdded(currAnpClass) >= instancesPerClass
      continue; 
   end
   
   % check how much we can still add, and compare it with the folder
   % contents
   currAnpFolderDir = [dataDir '/' currAnpFolder.name];
   currImages = dir([currAnpFolderDir '/*.jpg']);
   numImagesInCurrFolder = numel(currImages);
   numImagesToExtract = min(numImagesInCurrFolder, instancesPerClass - amountAdded(currAnpClass));
   numImagesToExtract = min(numImagesToExtract, maxInstancesPerFolder);
   
   % Create new folder if non-existent
   
   newAnpDir = [newDatasetDir '/' setSubDir '/' currAnpFolder.name];
   if ~exist(newAnpDir, 'dir')
    mkdir(newAnpDir);
   end
   
   disp(['Copying ' num2str(numImagesToExtract) ' images  out of ' num2str(numImagesInCurrFolder)])
   numInstancesAddedForFolder = 0;
   % Copy the images
   for j=1:numImagesToExtract
      currImg = currImages(j);
      copyfile([currAnpFolderDir '/' currImg.name], [newAnpDir '/' currImg.name]);
      actualCount = actualCount + 1;
      numInstancesAddedForFolder = numInstancesAddedForFolder + 1;
   end
   % Track the new additions
   amountAdded(currAnpClass) = amountAdded(currAnpClass) + numInstancesAddedForFolder;
end

disp('Finished creating dataset:')
disp(amountAdded)
