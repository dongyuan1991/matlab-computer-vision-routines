function [visualHull,image] = VisHull( x,y,z )

if ~exist( 'dinoFileRead.m', 'file' )
    addpath( '~/Code/file_management/' );
end

THRESH_VAL = 0.19;
visualHull = -1*ones( size( x ) );
[s,P,numImages] = dinoFileRead( '~/Data/dinoRing/dinoR_par.txt' );
%obtain camera centers
%c = cell( numImages,1);
image = cell(numImages,1);
for index=1:numImages
    filename = sprintf( '~/Data/dinoRing/dinoR%04d.png', index );
    image{index,1} = im2bw( im2double( rgb2gray( imread( filename ) ) ), THRESH_VAL );
    image{index,1} = bwmorph( image{index,1}, 'dilate',  10 ); % was 10 until mar24,2010
    image{index,1} = bwmorph( image{index,1}, 'erode', 7 );  % was 7 until mar24,2010
end

bad_silhouettes = [10 ; 11 ;16; 17 ;18];
%bad_silhouettes = [6];   % CHANGED
%num_good_silhouettes = 43;

for p = 1:size(visualHull,1)
    for q = 1:size(visualHull,2)
        for r = 1:size(visualHull,3)
            for idx = 1:numImages
                X_i = [ x(p,q,r) ; y(p,q,r) ; z(p,q,r) ; 1.0 ];
                x_i = projectToImage( P{idx},X_i );
                bad_sil = contains( bad_silhouettes,idx );  %isempty( find( bad_silhouettes == idx ) ); 
                %for sil_idx = 1:
                if( ~bad_sil && projectsToImage(x_i,image{idx,1}) && (~(image{idx,1}(x_i(2,1),x_i(1,1)) == 1)) )
                    visualHull(p,q,r) = 1;
                end
                % can't say the following, because photo may only capture
                % subset of silhouette
                
                %if( ~projectsToImage( x_i,image{idx,1} ) )
                %    visualHull(p,q,r) = 1;
                %end
            end
            
        end
    end
end

end % end function


function [isMemberOf] = contains( A, value )
    isMemberOf = false;
    for i = 1:size( A,1 )
        for j = 1:size( A,2 )
            if( A(i,j) == value )
                isMemberOf = true;
            end
        end
    end
end

function x = projectToImage( P, X )
    x = P * X;
    w = x(3,1);
    % now normalize -- don't bother with 3rd coord
    x(1,1) = round( x(1,1) / w );
    x(2,1) = round( x(2,1) / w );
    x(3,1) = round( x(3,1) / w );

end

% ensures that voxel projects to image, but is also not a boundary pixel
function projBool = projectsToImage( p_1,im )
    x1 = int16( round( p_1(1,1) ) );
    y1 = int16( round( p_1(2,1) ) );
    %if( ( x1 <= (640-3) ) && ( x1 > (0+3) ) && ( y1 <= (480-3) ) && ( y1 >
    %(0+3) ) )
    if( x1 <= size(im,2) && x1 > 0 && ( y1 <= size(im,1) ) && y1 > 0 )
        projBool = true;
    else
        projBool = false;
    end
end
