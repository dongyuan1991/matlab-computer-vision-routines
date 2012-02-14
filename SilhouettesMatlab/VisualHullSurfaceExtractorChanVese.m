function [x,y,z,phi] = VisualHullSurfaceExtractorGAC( visHull )
    %
    visHullInv = ~visHull;
    
    Nx = 100;
    Ny = 100;
    Nz = 100;
    x_lo = -0.1;%-0.08;
    x_hi = 0.1;%0.05; 
    y_lo = -0.1;%-0.03;
    y_hi = 0.1;%0.09; 
    z_lo = -0.1;%-0.08;
    z_hi = 0.1;%0.03;
    dx = (x_hi-x_lo)/Nx;
    dy = (y_hi-y_lo)/Ny;
    dz = (z_hi-z_lo)/Nz;
    dX = [dx dy dz];
    X = (x_lo:dx:x_hi)';
    Y = (y_lo:dy:y_hi)';
    Z = (z_lo:dz:z_hi)';
    [x,y,z] = meshgrid(X,Y,Z); 


    phi_init = (x).^2 + (y).^2 + (z).^2 - 0.008;
    phi_init = isoReinit( phi_init );
    phi = phi_init;
    
    delta_t = 2; n_iters = 3;
    contour_weight = 1; expansion_weight = 1;
    phi = ac_GAC_model(visHullInv, phi, contour_weight, expansion_weight, ...
                        delta_t, n_iters, 0 );
    phi(1,:,:) = 100;
    phi(101,:,:) = 100;
    phi(:,1,:) = 100;
    phi(:,101,:) = 100;
    phi(:,:,1) = 100;
    phi(:,:,101) = 100;
end