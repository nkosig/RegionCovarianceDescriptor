%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Region Covariance: A Fast Descriptor for Detection and Classification
%
%  Nkosikhona Gumede
%  University of KwaZulu Natal
%  208504751@stu.ukzn.ac.za
%  Aug 2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RegionCovariance(object,target)

global Co;

%function RegionCovariance(object,target)

disp('reading images');
RGBo = imread(object);
RGBt = imread(target);

disp('Calculating Feature Images');
Fo = FeatureImage(RGBo);
Ft = FeatureImage(RGBt);

disp('Calculating Object Image P and Q');
Po = TensorIntImage(Fo);
Qo = Tensor2ndOrderInt(Fo);

[ho,wo,~] = size(RGBo);

disp('Calculating Object Image Covariance Matrices C1 - C5');
Co(1,:,:) = RCovariance(Po,Qo,1,1,ho,wo);
Co(2,:,:) = RCovariance(Po,Qo,1,1,ho,floor(wo/2));
Co(3,:,:) = RCovariance(Po,Qo,1,wo-floor(wo/2),ho,wo);
Co(4,:,:) = RCovariance(Po,Qo,1,1,floor(ho/2),wo);
Co(5,:,:) = RCovariance(Po,Qo,ho-floor(ho/2),1,ho,wo);

disp('Calculating Target Image P and Q');
Pt = TensorIntImage(Ft);
Qt = Tensor2ndOrderInt(Ft);

disp('Performing initial search');
[BM, Cz] = NearestNeigborSearch(squeeze(Co(1,:,:)),Pt,Qt,ho,wo);

BM = sortrows(BM, 5);

BMt = BM(1:1000,:);

%[M index] = min(BM(:,1));
%Loc = BM(index,2:5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Brute search algorithm on best matching 1000 location using Covariance 
% matrices C2 - C5

for k = 1:1000
  
  yd = round((BMt(k,3) - BMt(k,1))/2 + BMt(k,1));
  xd = round((BMt(k,4) - BMt(k,2))/2 + BMt(k,2));
  
  Ct2 = RCovariance(Pt,Qt,BMt(k,1),BMt(k,2),BMt(k,3),xd);
  Ct3 = RCovariance(Pt,Qt,BMt(k,1),xd,BMt(k,3),BMt(k,4));
  Ct4 = RCovariance(Pt,Qt,BMt(k,1),BMt(k,2),yd,BMt(k,4));
  Ct5 = RCovariance(Pt,Qt,yd,BMt(k,2),BMt(k,3),BMt(k,4));
  
  d2 = CovarianceDistance(squeeze(Co(2,:,:)),Ct2); 
  d3 = CovarianceDistance(squeeze(Co(3,:,:)),Ct3);
  d4 = CovarianceDistance(squeeze(Co(4,:,:)),Ct4);
  d5 = CovarianceDistance(squeeze(Co(5,:,:)),Ct5);
  
  BMt(k,6:9) = [d2 d3 d4 d5];
  
  BMt(k,10) = BMt(k,5) + BMt(k,6) + BMt(k,7) + BMt(k,8) + BMt(k,9) - max(BMt(k,5:9));
end

BMt = sortrows(BMt, 10); % Sort best matching matrix BM and store best 1000 to best matching target matrix BMt

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

It = rgb2gray(RGBt);
It = double(It);

%  Draw rectangle around matching area on target image

for j = 1:1
  Loc = BMt(j,1:4);

  hs = Loc(1);
  ws = Loc(2);
  hf = Loc(3);
  wf = Loc(4);

  It(hs:hf,ws) = ones((hf-hs+1),1);
  It(hs:hf,wf) = ones((hf-hs+1),1);
  It(hs,ws:wf) = ones(1,(wf-ws+1));
  It(hf,ws:wf) = ones(1,(wf-ws+1));

end 

% Display both object and target image
figure;
Io = rgb2gray(RGBo);
imshow(Io);

figure;
It = uint8(It);
imshow(It)

end