function doubletorus_test(type)

surface = doubletorus();

unix('rm ./results/log.txt');                                                   
unix('rm ./results/iteration.dat');                                             
unix('touch ./results/iteration.dat');                                          
                                                                                
diary('./results/log.txt');                                                     
diary on;

sys_pmt.Nspecies = 2;                                                           
sys_pmt.Nblend   = 1;                                                           
sys_pmt.Nblock   = 2;                                                           
sys_pmt.Ndeg     = 100; 
type =1;
                                                        
if type == 1                                                                    
    sys_pmt.fA       = 0.5;                                                     
    sys_pmt.chiAB    = 0.15;
    initType = 1;
    Radius = 12;
    Mthd.Iter = 'Euler'; 
    Mthd.PDE = 'ImplicitCN';
    initrefine = 0; % 初始网格的加密次数
    maxrefine = 1; % 计算过程中的网格加密次数
elseif type == 2
    sys_pmt.fA       = 0.5;                                                     
    sys_pmt.chiAB    = 0.15;
    Radius = 12;    
    initType = 2;
    Mthd.Iter = 'Euler'; 
    Mthd.PDE = 'ImplicitCN';
    initrefine = 0; % 初始网格的加密次数
    maxrefine = 1; % 计算过程中的网格加密次数
elseif type == 3                                                                  
    sys_pmt.fA       = 0.2;                                                     
    sys_pmt.chiAB    = 0.25;
    initType = 1;
    Radius = 12;
    Mthd.Iter = 'Euler'; 
    Mthd.PDE = 'ImplicitCN';
    initrefine = 1; % 初始网格的加密次数
    maxrefine = 2; % 计算过程中的网格加密次数
else type == 4
    sys_pmt.fA       = 0.2;                                                     
    sys_pmt.chiAB    = 0.25;
    initType = 3;
    Radius = 12;
    Mthd.Iter = 'Euler'; 
    Mthd.PDE = 'ImplicitCN';
    initrefine = 0; % 初始网格的加密次数
    maxrefine = 1; % 计算过程中的网格加密次数

end 

                                                                
                                                                                
chiN = sys_pmt.chiAB*sys_pmt.Ndeg;


[node,elem] = surface.initmesh('./meshdata/doubletorussurface.mat');

for i=1:initrefine
    [node, elem] = smeshuniformrefine(node, elem);
    node = surface.project(node);
end

ndof = size(node, 1);                                                           
mu = zeros(2, ndof);                                                            
w = zeros(2, ndof);

if initType == 1
    mu(1, :) = chiN*(-1 + 2*rand(1, ndof));
    mu(2, :) = chiN*(-1 + 2*rand(1, ndof));
elseif initType == 2
    mu(2, :) = chiN*sin(8*pi*node(:, 1));
else initType == 3
    mu(2, :) = chiN*sin(8*pi*node(:, 2));
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

[cmp_mesh, cmp_pmt, scft] = diblockmain(init_mesh, cmp_mesh, cmp_pmt, scft, scftAux, sys_pmt, Mthd);
save(['doubletorussurface', int2str(type), '.mat'])
diary off;
