%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Filename: FeatureImage.m
%
%  Description: function to calculates the feature image from the image. 
%  This function calculates the 9 features for each pixel in the image as described
%  by equation 13
%  Region Covariance: A Fast Descriptor for Detection and Classification
%
%  F(x,y) = [x y R(x,y) G(x,y) B(x,y) |dI/dx| |dI/dy| |d2I/dx2| |d2I/dy2|]
%
%  Nkosikhona Gumede
%  University of KwaZulu Natal
%  208504751@stu.ukzn.ac.za
%  Aug 2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [F, I] = FeatureImage(RGB)

% Convert to grayscale (intensity) image
r = RGB(:, :, 1);
g = RGB(:, :, 2);
b = RGB(:, :, 3);

I = rgb2gray(RGB); % Convert to grayscale (intensity) image 
%I = ((r + g + b)/3);
I = im2double(I);

%I = squeeze(I(:,:,3));

[h,w,~] = size(RGB);

F = zeros(h,w,9);     % Feature image template  (H x W x d matrix)

for i=1:h
    for j=1:w
        F(i,:,1) = i*ones(1,w);   % Pixel x location
        F(:,j,2) = j*ones(h,1);   % Pixel y location
    end
end

F(:,:,3:5) = im2double(RGB);    % RGB pixel values

xdev1 = [-1 0 1]';   % first derivate calculation filter
ydev1 = xdev1';

xdev2 = [-1 2 -1]';  % second derivate calculation filter
ydev2 = xdev2';

F(:,:,6) = abs(conv2(I,xdev1,'same'));    % Absolute of first derivative w.r.t x |dI/dx|
F(:,:,7) = abs(conv2(I,ydev1,'same'));    % Absolute of first derivative w.r.t y |dI/dy|
F(:,:,8) = abs(conv2(I,xdev2,'same'));    % Absolute of second derivative w.r.t x |d2I/dx2|
F(:,:,9) = abs(conv2(I,ydev2,'same'));    % Absolute of second derivative w.r.t y |d2I/dy2|

%I = im2uint8(I);

%F = uint8(F);  %Covert back to uint8
end