clear all; clc,

root = pwd;

run('VLFEATROOT/toolbox/vl_setup')

%path2images = '/datos1/vision/lab9Detection/TrainCrops/';
path2images = 'C:\Users\usuario\Dropbox\Universidad\Maestria2\Vision\Textures\images\TrainCrops\';

% cd C:\Users\usuario\Dropbox\Universidad\Maestria2\Vision\Textures

cd(path2images);

files = dir
directoryNames = {files([files.isdir]).name}
directoryNames = directoryNames(~ismember(directoryNames,{'.','..'}))

images = cell(0, 4);

for i=1:length(directoryNames)
  folder = directoryNames{i};
  cd(folder)
  ims = dir('*.jpg');
  
    for j=1:length(ims)
    images{end + 1, 1} = imread(ims(j).name);
    end
    
 cd ..
end

%% MULTISCALE %%
% Database images (or crops) do not come in a fixed size. Average size for
% crops is 100x125 pixels. We rescale them to three other fixed sizes

[lengthimages size2] = size(images);

for i=1:lengthimages
    
    images{i,2} =  imresize(images{i,1}, [100 125]);
    images{i,3} =  imresize(images{i,1}, [70 88]);
    images{i,4} =  imresize(images{i,1}, [50 62]);
    
end

%% HOG %%
% Apply HOG to each scale in the image cell

imageHogs = cell(lengthimages, size2);

for i=1:lengthimages
    for j=1:size2
            
        im = images{i,j};    
        im = im2single(im);

        cellSize = 8;
        hog = vl_hog(im, cellSize) ;
        %imhog = vl_hog('render', hog, 'verbose') ;
        %clf ; imagesc(imhog) ; colormap gray ;
        imageHogs{i,j} = hog;
    end
end

cd ..
%% NEGATIVES FOR THE SVM
% To produce negatives for the SVM, we extract random patches from images
% in the complete train set and we compute their HOG. It is very unlikely
% that these patches correspond to positives.

cd TrainImages

files = dir
directoryNames = {files([files.isdir]).name}
directoryNames = directoryNames(~ismember(directoryNames,{'.','..'}))

negs = cell(0, 1);

for i=1:length(directoryNames)
  folder = directoryNames{i};
  cd(folder)
  ims = dir('*.jpg');
  
    for j=1:length(ims)
    ima = imread(ims(j).name);
    ima = im2single(ima);
    [size1 size2] = size(ima);
    
    
    if size1 > 101 && size2 > 126
        xo = ceil(rand()*(size1 - 101));
        xf = xo + 100;
        yo = ceil(rand()*(size2 - 126));
        yf = yo + 125;
    
        cellSize = 8;
        hogneg = vl_hog(ima(xo:xf, yo:yf), cellSize);
        negs{end + 1, 1} = hogneg;
    end
    end
    
 cd ..
end

%% TRAIN THE SVM %%
% Use previosuly acquired positives and negatives to train the SVM.

positives = imageHogs(:,2); numPos = length(positives);
numNeg = length(negs);

pos = zeros(13*16*31, numPos);
neg = zeros(13*16*31, numNeg);

for i=1:numPos
    pos(:,i) = reshape(positives{i}, 13*16*31, 1);
end

for i=1:numNeg
    neg(:,i) = reshape(negs{i}, 13*16*31, 1);
end

annotationsPos = ones(1, size(pos, 2));
annotationsNeg = -ones(1, size(neg, 2));

Annotations = cat(2, annotationsPos, annotationsNeg);

X = horzcat(pos, neg);

% Defie confidence parameter
C = 10 ;
lambda = 1 / (C * (numPos + numNeg)) ;

% Learn the SVM using an SVM solver
[w,b] = vl_svmtrain(X,Annotations,lambda,'epsilon',0.01,'verbose') ;

cd(root)

save('trainedSVM.mat','w','b')

cd ..
clear all; clc,

root = pwd;

run('VLFEATROOT/toolbox/vl_setup')

%path2images = '/datos1/vision/lab9Detection/TrainCrops/';
path2images = 'C:\Users\usuario\Dropbox\Universidad\Maestria2\Vision\Textures\images\TrainCrops\';

% cd C:\Users\usuario\Dropbox\Universidad\Maestria2\Vision\Textures

cd(path2images);

files = dir
directoryNames = {files([files.isdir]).name}
directoryNames = directoryNames(~ismember(directoryNames,{'.','..'}))

images = cell(0, 6);

for i=1:length(directoryNames)
  folder = directoryNames{i};
  cd(folder)
  ims = dir('*.jpg');
  
    for j=1:length(ims)
    images{end + 1, 1} = imread(ims(j).name);
    end
    
 cd ..
end

%% MULTISCALE %%
% Database images (or crops) do not come in a fixed size. Average size for
% crops is 100x125 pixels. We rescale them to three other fixed sizes

[lengthimages size2] = size(images);

for i=1:lengthimages
    
    images{i,2} =  imresize(images{i,1}, [125 100]);
    images{i,3} =  imresize(images{i,1}, [88 70]);
    images{i,4} =  imresize(images{i,1}, [62 50]);
    images{i,5} =  imresize(images{i,1}, [50 40]);
    images{i,6} =  imresize(images{i,1}, [38 30]);
    
end

%% HOG %%
% Apply HOG to each scale in the image cell

imageHogs = cell(lengthimages, size2);

for i=1:lengthimages
    for j=1:size2
            
        im = images{i,j};    
        im = im2single(im);

        cellSize = 8;
        hog = vl_hog(im, cellSize, 'numOrientations', 12);
        %imhog = vl_hog('render', hog, 'verbose') ;
        %clf ; imagesc(imhog) ; colormap gray ;
        imageHogs{i,j} = hog;
    end
end

cd ..
%% NEGATIVES FOR THE SVM
% To produce negatives for the SVM, we extract random patches from images
% in the complete train set and we compute their HOG. It is very unlikely
% that these patches correspond to positives.

cd TrainImages

files = dir
directoryNames = {files([files.isdir]).name}
directoryNames = directoryNames(~ismember(directoryNames,{'.','..'}))

negs = cell(0, 1);

for count=1:5
    for i=1:length(directoryNames)
        folder = directoryNames{i};
        cd(folder)
        ims = dir('*.jpg');
  
        for j=1:length(ims)
            ima = imread(ims(j).name);
            ima = im2single(ima);
            [size1 size2] = size(ima);
    
    
            if size1 > 101 && size2 > 126
                xo = ceil(rand()*(size1 - 101));
                xf = xo + 100;
                yo = ceil(rand()*(size2 - 126));
                yf = yo + 125;
    
                cellSize = 8;
                hogneg = vl_hog(ima(xo:xf, yo:yf), cellSize, 'numOrientations', 12);
                negs{end + 1, 1} = hogneg;
            end
        end
        cd ..
    end
    
end
cd ..
%% TRAIN THE SVM %%
% Use previosuly acquired positives and negatives to train the SVM.
cd ..

positives = imageHogs(:,2); numPos = length(positives);
numNeg = length(negs);

pos = zeros(13*16*40, numPos);
neg = zeros(13*16*40, numNeg);

for i=1:numPos
    pos(:,i) = reshape(positives{i}, 13*16*40, 1);
end

for i=1:numNeg
    neg(:,i) = reshape(negs{i}, 13*16*40, 1);
end

annotationsPos = ones(1, size(pos, 2));
annotationsNeg = -ones(1, size(neg, 2));

Annotations = cat(2, annotationsPos, annotationsNeg);

X = horzcat(pos, neg);

% Defie confidence parameter
C = 10 ;
lambda = 1 / (C * (numPos + numNeg)) ;

% Learn the SVM using an SVM solver

% cellVectors{i} = [cellHogVec{i},cellHogVecNeg{i}];
w = cell(1,size2-1);
b = w;
for i = 1:size2-1
    [w{i},b{i}] = vl_svmtrain(X,Annotations,lambda,'epsilon',0.01,'verbose');
end

cd(root)
save('trainedSVM4.mat','w','b')


% 
% w = vl_svmtrain(X,Annotations,lambda,'epsilon',0.01,'verbose') ;
% 
% cd(root)
% 
% save('trainedSVM_pyramid-6_orientations-12.mat','w')



