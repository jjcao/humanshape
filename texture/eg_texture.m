clear;clc;close all;
MYTOOLBOXROOT='../../jjcao_code/toolbox/';
%MYTOOLBOXROOT='../';
addpath ([MYTOOLBOXROOT 'jjcao_mesh'])
addpath ([MYTOOLBOXROOT 'jjcao_common'])
addpath ([MYTOOLBOXROOT 'jjcao_interact'])
addpath ([MYTOOLBOXROOT 'jjcao_plot'])
addpath ([MYTOOLBOXROOT 'jjcao_interact'])
addpath ([MYTOOLBOXROOT 'jjcao_io'])

DEBUG = 1;DEBUG1 = 1;

%% load input mesh, its texture image
[FV.vertices,FV.faces,FV.vnormal, FV.vt, FV.ft, FV.fnormal] = read_obj('alison_tri.obj');% rp1, alison_tri
if DEBUG1
    patch('Faces',FV.ft,'Vertices',FV.vt, 'EdgeColor', 'r'); axis equal; axis on; view3d zoom; title('input mesh');
end

im = imread('rp_alison_rigged_001_dif.jpg');%rp1-1024, rp_alison_rigged_001_dif, 
%im = imread('rp_eric_rigged_001_dif.jpg'); % no improve using the high
%resolution

if(~isa(im,'double'))
    im=double(im)./255;
end

% show texture of input mesh
if DEBUG
    VT = [FV.vt(:,1)*size(im,1), FV.vt(:,2)*size(im,2)];
    [rows,cols]=meshgrid(1:size(im,2),1:size(im,1));
    uvcolor= zeros(0);
    facevertexcdata = FV.vertices;
    for col=1:3
        uvcolor(:,col) = interp2(rows,cols,im(:,:,col), VT(:,1),size(im,1)+1-VT(:,2),'cubic');
    end
    for col=1:3
        facevertexcdata(FV.faces(:,col),:) = uvcolor(FV.ft(:,col),:);
    end
    
    figure;title('input mesh with texture');
    p=patch('Faces',FV.faces,'Vertices',FV.vertices, 'FaceVertexCData', facevertexcdata); 
    p.EdgeColor = 'none'; 
    p.FaceColor = 'interp'; axis equal; axis off; view3d rot;     
    %light;
    %p.FaceLighting = 'phong';
end

%% load reconstructed mesh
%[FVr.points, FVr.faces] = read_off('alison_dense2.off');%, alison_nrd.obj, alison_dense2
%[FVr.points, FVr.faces] = read_obj('alison_nrd.obj');%NRDmesh.off, alison_nrd.obj,
FVr = load('alison_dense_icp.mat');%NRDmesh.mat,NRD2,alison_icp,alison_dense_icp


%% vr is vertex of reconstructed mesh, use the color of its neariset vertex on the input mesh as its color. 
% result is acceptable when the reconstructed mesh is dense for face.
if DEBUG1
    idx = knnsearch(FV.vertices,FVr.points,'k',1); 
    FVr.facevertexcdata = facevertexcdata(idx,:);
    figure; title('reconstructed mesh with texture');
    p=patch('Faces',FVr.faces,'Vertices',FVr.points, 'FaceVertexCData', FVr.facevertexcdata);     
    p.FaceColor = 'interp'; axis equal; axis off; view3d rot;
    p.EdgeColor = 'none'; 
    %figure;p=patch('Faces',FVr.faces,'Vertices',FVr.points, 'EdgeColor', 'b');  
    %write_off('NRDmesh.off',FVr.points,FVr.faces);
    %write_off('NRDmesh.off',FVr.points,FVr.faces,FVr.facevertexcdata);
end

%% project input mesh to reconstructed mesh by knn
if DEBUG
    idx = knnsearch(FVr.points,FV.vertices,'k',3); 
    %verts = [FVr.points(idx(:,1),:) FVr.points(idx(:,2),:) FVr.points(idx(:,3),:)];
    verts = FVr.points(idx(:,1),:);
    figure; title('projected input mesh with texture');
    p=patch('Faces',FV.faces,'Vertices',verts, 'FaceVertexCData', facevertexcdata); 
    p.EdgeColor = 'none'; 
    p.FaceColor = 'interp'; axis equal; axis off; view3d rot;
end
%% patcht is wrong for the data.
%VT_flipy = VT;
%VT_flipy(:,2) = 1-VT(:,2);%VT_flipy(:,1) = 1-VT(:,1);
%Options.EdgeColor='none';
%patcht(FF,VV,TF,VT_flipy,I,Options);axis off; view3d

%% pick points
%PointCloud = perform_point_picking( VV',FF' );axis off; axis equal;
% rp1tri:�Ǽ�1229������ü�м䶥��3671�����6947;�Һ��4645.
% view3d rot
% global PointCloudIndex;
% set(gcf,'WindowButtonDownFcn',{@callbackClickA3DPoint,PointCloud}); % set the callbak
% set(gcf,'WindowButtonUpFcn',{}); % set the callbak

