function ellipsoidsurface_test(type)
surface = ellipsoidsurface();

unix('rm ./results/log.txt');                                                   
unix('rm ./results/iteration.dat');                                             
unix('touch ./results/iteration.dat');                                          
                                                                                
diary('./results/log.txt');                                                     
diary on;

sys_pmt.Nspecies = 2;                                                           
sys_pmt.Nblend   = 1;                                                           
sys_pmt.Nblock   = 2;                                                           
sys_pmt.Ndeg     = 100;                                                         

type = 6;
 
if type == 1                                                                    
    sys_pmt.fA       = 0.2;                                                     
    sys_pmt.chiAB    = 0.25;
    initType = 2;
    Radius = 1;                                                        
    Mthd.Iter = 'Euler'; 
    Mthd.PDE = 'ImplicitCN';
    initrefine = 0; 
    maxrefine = 1; 
elseif type == 2                                                                  
    sys_pmt.fA       = 0.2;                                                     
    sys_pmt.chiAB    = 0.25;
    initType = 2;
    Radius = 1;                                                        
    Mthd.Iter = 'Euler'; 
    Mthd.PDE = 'ImplicitCN';
    initrefine = 0; 
    maxrefine = 1;

elseif type == 3
    sys_pmt.fA       = 0.5;                                                     
    sys_pmt.chiAB    = 0.15;
    initType = 2;
    Radius = 2;                                                        
    Mthd.Iter = 'Euler'; 
    Mthd.PDE = 'ImplicitCN';
    initrefine = 0; 
    maxrefine = 1;
elseif type == 4
    sys_pmt.fA       = 0.5;                                                     
    sys_pmt.chiAB    = 0.15;
    initType = 3;
    Radius = 1;                                                        
    Mthd.Iter = 'Euler'; 
    Mthd.PDE = 'ImplicitCN';
    initrefine = 0; 
    maxrefine = 1;
elseif type == 5
    sys_pmt.fA       = 0.5;                                                     
    sys_pmt.chiAB    = 0.15;
    initType = 4;
    Radius = 1;                                                        
    Mthd.Iter = 'Euler'; 
    Mthd.PDE = 'ImplicitCN';
    initrefine = 0; 
    maxrefine = 1;
elseif type == 6
    sys_pmt.fA       = 0.5;                                                     
    sys_pmt.chiAB    = 0.15;
    initType = 5;
    Radius = 1;                                                        
    Mthd.Iter = 'Euler'; 
    Mthd.PDE = 'ImplicitCN';
    initrefine = 0; 
    maxrefine = 1;
end 
                                                                
                                                                                
chiN = sys_pmt.chiAB*sys_pmt.Ndeg;

[node,elem] = surface.initmesh('./meshdata/ellipsoidsurface.mat');
for i=1:initrefine
    [node, elem] = smeshuniformrefine(node, elem);
    node = surface.project(node);
end

ndof = size(node, 1);                                                           
mu = zeros(2, ndof);                                                            
w = zeros(2, ndof);

if initType == 1
    mu(2, 1:12) = 1;
elseif initType ==2 
    mu(1, :) = chiN*(-1 + 2*rand(1, ndof));
    mu(2, :) = chiN*(-1 + 2*rand(1, ndof));
elseif initType == 3
    theta = atan2(node(:,2), node(:,1));
    theta = (theta>= 0).*theta + (theta<0).*(theta+2*pi);
    mu(2, :) = chiN*sin(8*theta);
elseif initType == 4
    mu(2, :) = chiN*sin(8*pi*node(:, 1));
elseif initType == 5
    theta = atan2(node(:,2), node(:,1));
    theta = (theta>= 0).*theta + (theta<0).*(theta+2*pi);
    phi = atan2(node(:,3), node(:,2));
    phi = (phi>= 0).*phi + (phi<0).*(phi+2*pi);
    mu(2, :) = chiN*sin(8*theta+8*phi);
else
	initdata = load('../data/ortho-test1-1.mat');
    mu(1,:)=initdata.scft.mu(1,:);
    mu(2,:)=initdata.scft.mu(2,:);
    clear initdata;
end

w(1,:) = mu(1,:) - mu(2,:);
w(2,:) = mu(1,:) + mu(2,:);

init_mesh.surface = surface;
init_mesh.node = node;
init_mesh.elem = elem;

%%%%% generate computational meshgrid
cmp_mesh = get_cmp_mesh(init_mesh, Radius);
cmp_pmt = get_cmp_pmt(sys_pmt, init_mesh);
[scft, scftAux] = get_scft_data(sys_pmt, cmp_pmt);

cmp_pmt.maxrefine = maxrefine;

scft.w = w;
scft.mu(1,:) = 0.5*(scft.w(1,:)+scft.w(2,:));
scft.mu(2,:) = 0.5*(scft.w(2,:)-scft.w(1,:));

scft.rho(1,:) = 0.5 + scft.mu(2,:)/chiN;
scft.rho(2,:) = 1.0 - scft.rho(1,:);

[cmp_mesh, cmp_pmt, scft]=diblockmain(init_mesh, cmp_mesh, cmp_pmt, scft, scftAux, sys_pmt, Mthd);
save(['ellipsoidsurface', int2str(type), '.mat'])
diary off;