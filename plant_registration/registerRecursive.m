%REGISTER_VIA_SURFACE_SUBDIVISION Do a coarse to fine, recursive
%registration.
function [Y1,Y2,Y3] = registerRecursive( X,Y,opt,MIN_SIZE )
    T = cpd_register(X,Y,opt);
    
    [Y1,Y2,Y3] = registerPoints( X,T.Y,opt,MIN_SIZE );
end
 
function [X__,Y__,Z__] = registerPoints( X,Y,opt,MIN_SIZE )   
    if size(X,1) > MIN_SIZE && size(Y,1) > MIN_SIZE
        [R,T] = icp( X,Y );
        Y_icp = R*Y' + repmat(T',size(Y,1),1)';
        Y_icp = Y_icp';
        figure;
        plot3( X(:,1),X(:,2),X(:,3), '.b', 'markersize',1 )
        hold on
        plot3( Y_icp(:,1),Y_icp(:,2),Y_icp(:,3), '.r', 'markersize',1 )
            %[T] = cpd_register(X,Y,opt);
            %Y1_ = T.Y(:,1);
            %Y2_ = T.Y(:,2);
            %Y3_ = T.Y(:,3);
        
        % after initial registration, use more refined
        opt.fgt = 0;
        opt.method = 'rigid';
        opt.normalize = 1;
        opt.outliers = 0.4;
        
        Y = Y_icp;
        %T = 0;
        %q = [X(:,1);Y1_]
        min_x = min( [ X(:,1); Y(:,1) ] ); %Y1_ ] );
        max_x = max( [ X(:,1); Y(:,1) ] );%Y1_ ] );
        min_y = min( [ X(:,2); Y(:,2) ] );%Y2_ ] );
        max_y = max( [ X(:,2); Y(:,2) ] );%Y2_ ] );
        min_z = min( [ X(:,3); Y(:,3) ] );%Y3_ ] ); 
        max_z = max( [ X(:,3); Y(:,3) ] );%Y3_ ] );
        % padding does not work because 
        % we are just dividing in half.
        %pad = 0.2;
        
        %width = dist(min_x,max_x);
        %height = dist(min_y,max_y);
        %depth = dist(min_z,max_z);
        
        left_x   = min_x; %- pad*width
        right_x  = max_x; %+ pad*width
        top_x    = max_y; %+ pad*height
        bottom_x = min_y; %- pad*height
        back_x   = min_z; %- pad*depth
        front_x  = max_z; %+ pad*depth
        
        % this use of X co-ords as the dividing space is on purpose
        left_y   = min_x;
        right_y  = max_x;
        top_y    = max_y;
        bottom_y = min_y;
        back_y   = min_z;
        front_y  = max_z ;     
        
        m_width  = left_x+((right_x-left_x)/2);
        m_height = bottom_x+((top_x-bottom_x)/2);
        m_depth = back_x+((front_x-back_x)/2 );
        
        m_width_y  = left_y+((right_y-left_y)/2);
        m_height_y = bottom_y+((top_y-bottom_y)/2);
        m_depth_y = back_y+((front_y-back_y)/2 );
        
        Y1_ = Y(:,1);
        Y2_ = Y(:,2);
        Y3_ = Y(:,3);
        
        %{
        idx_x_000 = find( X1_ < m_width & X2_ < m_height & X3_ < m_depth );
        idx_x_001 = find( X1_ < m_width & X2_ < m_height & X3_ >= m_depth );
        idx_x_010 = find( X1_ < m_width & X2_ >= m_height & X3_ < m_depth );
        idx_x_011 = find( X1_ < m_width & X2_ >= m_height & X3_ >= m_depth );
        idx_x_100 = find( X1_ >= m_width & X2_ < m_height & X3_ < m_depth );
        idx_x_101 = find( X1_ >= m_width & X2_ < m_height & X3_ >= m_depth );
        idx_x_110 = find( X1_ >= m_width & X2_ >= m_height & X3_ < m_depth );
        idx_x_111 = find( X1_ >= m_width & X2_ >= m_height & X3_ >= m_depth );
        %}
        
        k = 10;
        max_dist = 7;
        idx_y_000 = find( Y1_ < m_width_y & Y2_ < m_height_y & Y3_ < m_depth_y );
        idx_y_001 = find( Y1_ < m_width_y & Y2_ < m_height_y & Y3_ >= m_depth_y );
        idx_y_010 = find( Y1_ < m_width_y & Y2_ >= m_height_y & Y3_ < m_depth_y );
        idx_y_011 = find( Y1_ < m_width_y & Y2_ >= m_height_y & Y3_ >= m_depth_y );
        idx_y_100 = find( Y1_ >= m_width_y & Y2_ < m_height_y & Y3_ < m_depth_y );
        idx_y_101 = find( Y1_ >= m_width_y & Y2_ < m_height_y & Y3_ >= m_depth_y );
        idx_y_110 = find( Y1_ >= m_width_y & Y2_ >= m_height_y & Y3_ < m_depth_y );
        idx_y_111 = find( Y1_ >= m_width_y & Y2_ >= m_height_y & Y3_ >= m_depth_y );
        
        X_ur_000 = findPointstoRegister( X,Y(idx_y_000,:),k,max_dist )
        X_ur_001 = findPointstoRegister( X,Y(idx_y_001,:),k,max_dist )
        X_ur_010 = findPointstoRegister( X,Y(idx_y_010,:),k,max_dist )        
        X_ur_011 = findPointstoRegister( X,Y(idx_y_011,:),k,max_dist )        
        X_ur_100 = findPointstoRegister( X,Y(idx_y_100,:),k,max_dist )        
        X_ur_101 = findPointstoRegister( X,Y(idx_y_101,:),k,max_dist )        
        X_ur_110 = findPointstoRegister( X,Y(idx_y_110,:),k,max_dist )
        X_ur_111 = findPointstoRegister( X,Y(idx_y_111,:),k,max_dist )        

        
        
        %make fgt = 0 for the smaller subdivisions
        [Y1_000,Y2_000,Y3_000] = registerPoints( X_ur_000,Y(idx_y_000,:),opt,MIN_SIZE );
        %idx_x_000 = 0; idx_y_000 = 0;
        [Y1_001,Y2_001,Y3_001] = registerPoints( X_ur_001,Y(idx_y_001,:),opt,MIN_SIZE );
        %idx_x_001 = 0; idx_y_001 = 0;
        [Y1_010,Y2_010,Y3_010] = registerPoints( X_ur_010,Y(idx_y_010,:),opt,MIN_SIZE );
        %idx_x_010 = 0; idx_y_010 = 0;
        [Y1_011,Y2_011,Y3_011] = registerPoints( X_ur_011,Y(idx_y_011,:),opt,MIN_SIZE );
        %idx_x_011 = 0; idx_y_011 = 0;
        [Y1_100,Y2_100,Y3_100] = registerPoints( X_ur_100,Y(idx_y_100,:),opt,MIN_SIZE );
        %idx_x_100 = 0; idx_y_100 = 0;
        [Y1_101,Y2_101,Y3_101] = registerPoints( X_ur_101,Y(idx_y_101,:),opt,MIN_SIZE );
        %idx_x_101 = 0; idx_y_101 = 0;
        [Y1_110,Y2_110,Y3_110] = registerPoints( X_ur_110,Y(idx_y_110,:),opt,MIN_SIZE );
        %idx_x_110 = 0; idx_y_110 = 0;
        [Y1_111,Y2_111,Y3_111] = registerPoints( X_ur_111,Y(idx_y_111,:),opt,MIN_SIZE );
        %idx_x_111 = 0; idx_y_111 = 0;
        X__ = [Y1_000; Y1_001 ; Y1_010 ; Y1_011 ; Y1_100 ; Y1_101 ; Y1_110 ; Y1_111 ]; 
        Y__ = [Y2_000; Y2_001 ; Y2_010 ; Y2_011 ; Y2_100 ; Y2_101 ; Y2_110 ; Y2_111 ];  
        Z__ = [Y3_000; Y3_001 ; Y3_010 ; Y3_011 ; Y3_100 ; Y3_101 ; Y3_110 ; Y3_111 ]; 
   %{
    elseif size(X,1) > 100 && size(Y,1) > 100
        [R,T] = icp( X,Y );
        Y_icp = R*Y' + repmat(T',size(Y,1),1)';
        Y_icp = Y_icp';
        X__ = Y_icp(:,1);
        Y__ = Y_icp(:,2);
        Z__ = Y_icp(:,3);
    %}
    else
        X__ = Y(:,1);
        Y__ = Y(:,2);
        Z__ = Y(:,3);
    end

end
