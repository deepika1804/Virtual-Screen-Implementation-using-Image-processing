
function [x_coord,y_coord]=skinDetect2func(img)
    %% detecting the hand from the scene
    x_coord = 0;
    y_coord = 0;
    imshow(img);
    sz=size(img);
    r=1;g=2;b=3;y=1;u=2;v=3;
    yuv=img;
    region=yuv;
    for i=1:sz(1)
        for j=1:sz(2)
            yuv(i,j,y)=(img(i,j,r)+2*img(i,j,g)+img(i,j,b))/4;
            yuv(i,j,u)=img(i,j,r)-img(i,j,g);
            yuv(i,j,v)=img(i,j,b)-img(i,j,g);
        end
    end
    for i=1:sz(1)
        for j=1:sz(2)
            if yuv(i,j,u)>20 && yuv(i,j,u)<74
                region(i,j,r)=255;
                region(i,j,g)=255;
                region(i,j,b)=255;

            else
                region(i,j,r)=0;
                region(i,j,g)=0;
                region(i,j,b)=0;
            end
        end
    end
    out=region;
    
    out=im2bw(out);
    out=bwareaopen(out,100);
    out=imdilate(out,strel('diamond',4));
    
    res=out;
    cc=bwconncomp(res);
    arr=(cellfun('length',cc.PixelIdxList));
    newLabel=res;
    if ~isempty(round(arr))
        msz=0;
        for i=1:length(arr)
            if msz<arr(i:i)
                msz=arr(i:i);
                index=i;
            end
        end
        labels=labelmatrix(cc);
        newLabel=(labels==index);
        out=newLabel;
    end
    out=imfill(out,'holes');

   %% finding the tip of fingers by finding the max pixel
    [row,col,v] = find(out);
    x = max(row) ;
    y = col(find(row==max(row)));
    if size(y,1) > 0 && size(x,1) > 0
        x_coord = y(1);
        y_coord = x(1);
    end
    
end





