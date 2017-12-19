function [C,C2,croppedImg,bbox1] = findTransformedCoord(Im)
    %image conversion to binary
    keyIm = Im;
    [r c p] = size(keyIm);
    imR = squeeze(keyIm(:,:,1));
    imG = squeeze(keyIm(:,:,2));
    imB = squeeze(keyIm(:,:,3));
    imBinaryR = im2bw(imR,graythresh(imR));
    imBinaryG = im2bw(imG,graythresh(imG));
    imBinaryB = im2bw(imB,graythresh(imB));
    imBinary = imcomplement(imBinaryR & imBinaryG & imBinaryB);

    %edge detection of binary image.
    bw = bwareaopen(imBinary, 100);
    eroded = edge(imBinary,'Sobel');
    eroded = imclearborder(eroded);
    BW_out = bwpropfilt(eroded,'perimeter',100);
    Ibw = imBinary;
    Ifill = imfill(Ibw,'holes');
    Iarea = bwareaopen(Ifill,100);
    Ifinal = bwlabel(Iarea);            %assigning the labels to each object


    stat=regionprops(Ifinal,'all');     %extracting the region properties like area,perimeter
    if ~isempty(stat)
        for j=1:length(stat)
            bbox=stat(j).BoundingBox;
               if bbox(3)>20 && bbox(3)>20
                   bbox1=bbox;
                   bbox1(1)=bbox(1)+6;bbox1(2)=bbox(2)-2;
                   bbox1(3)=bbox(3)-4;bbox1(4)=bbox(4) + 50;
                   if bbox(4)>70,bbox1(2)=bbox(2) + 16; end
                   crop_im=imcrop(Ifinal,bbox1);
                   s=im2bw(crop_im,graythresh(crop_im));imshow(s)
                   final_area = stat(j).Area;
                   final_majoraxis = stat(j).MajorAxisLength;
                   final_minorAxis = stat(j).MinorAxisLength;
                  
               end
        end
    end
    %%cropping the image to keyboard size.
    croppedImg = imcrop(imBinary,bbox1);
    %% Find each of the four corners
    [y,x] = find(s);
    [~,loc] = min(y+x);
    C = [x(loc),y(loc)];
    [~,loc] = min(y-x);
    C(2,:) = [x(loc),y(loc)];
    [~,loc] = max(y+x);
    C(3,:) = [x(loc),y(loc)];
    [~,loc] = max(y-x);
    C(4,:) = [x(loc),y(loc)];
    %% Plot the corners
    imshow(s); hold all
    plot(C([1:4 1],1),C([1:4 1],2),'r','linewidth',3);
    %% Find the locations of the new  corners
    L = mean(C([1 4],1));
    R = mean(C([2 3],1));
    U = mean(C([1 2],2));
    D = mean(C([3 4],2));
    C2 = [L U; R U; R D; L D];
    
end