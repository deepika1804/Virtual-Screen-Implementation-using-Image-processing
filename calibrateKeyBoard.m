function [C,C2,bbox1,top_left_x,top_left_y,len_div,width_div] = calibrateKeyBoard(Im)
   
    [C,C2,croppedImg,bbox1] = findTransformedCoord(Im);
    %% Do the image transform
    figure
    T = cp2tform(C ,C2,'projective');
    IT = imtransform(croppedImg,T); 

    %% find the new coordinates
    [new_y,new_x] = find(IT);
    [~,loc] = min(new_y+new_x);
    C_new = [new_x(loc),new_y(loc)];
    [~,loc] = min(new_y-new_x);
    C_new(2,:) = [new_x(loc),new_y(loc)];
    [~,loc] = max(new_y+new_x);
    C_new(3,:) = [new_x(loc),new_y(loc)];
    [~,loc] = max(new_y-new_x);
    C_new(4,:) = [new_x(loc),new_y(loc)];
    
    %plot the grid
    imshow(IT); hold all
    plot(C_new([1:4 1],1),C_new([1:4 1],2),'r','linewidth',3);
    len = C_new(2,1) - C_new(1,1);
    width = C_new(3,2) - C_new(1,2);

    len_div = ceil(len/10);
    width_div = ceil(width/5);
    figure,imshow(IT);hold all
    
    %% draw grid lines
    for row = C_new(1,1) : len_div : C_new(2,1)+10
        line([row, row],[C_new(1,2), C_new(3,2)],'Color','red','LineStyle','-','LineWidth',3);
    end

    for column = C_new(1,2) : width_div : C_new(3,2)+10
        line([C_new(1,1), C_new(2,1)],[column , column ],'Color','red','LineStyle','-','LineWidth',3);

    end
    top_left_x = C_new(1,1);
    top_left_y = C_new(1,2);
  
end



