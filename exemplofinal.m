clc;
clear all;
close all;


imagemColorida = imread('BD/image(41).jpg');
imagemCinza = rgb2gray(imagemColorida);

figure, imshow(imagemCinza);

[mserRegions, mserConnComp] = detectMSERFeatures(imagemCinza, 'RegionAreaRange',[100 5000],'ThresholdDelta',4);
mserRegionsPixels = vertcat(cell2mat(mserRegions.PixelList));
% RegionAreaRange delimita o tamanho, em pixels, de area dos objetos a serem 
% determinados, com o uso de 'MaxAreaVariation', que no caso eh [100, 1000]

% ThresholdDelta eh a variação de limiar a ser determindada(regiões estáveis)
% São usadas 4 áreas diferentes

figure
imshow(imagemCinza)
hold on
plot(mserRegions, 'showPixelList', true,'showEllipses',false)
title('Regioes MSER')
hold off

% MSER regions são as regiões que possuem intensidade constante.

mserFiltro = zeros(size(imagemCinza));
ind = sub2ind(size(mserFiltro), mserRegionsPixels(:, 2), mserRegionsPixels(:,1));
mserFiltro(ind) = true;

edgeMask = edge(imagemCinza, 'Canny');

imagem_filtrada = mserFiltro & edgeMask;

strel = strel('disk', 1, 0);
imagem_filtrada_dilatada = imdilate(imagem_filtrada, strel);

stats = regionprops(mserConnComp, 'Extent', 'Eccentricity', 'Solidity', 'Image', 'BoundingBox');

filtro_regiao_filtrada = imagem_filtrada_dilatada;
filtro_regiao_filtrada(vertcat(mserConnComp.PixelIdxList{[stats.Eccentricity] > 0.995})) = 0;
filtro_regiao_filtrada(vertcat(mserConnComp.PixelIdxList{[stats.Extent] < 0.2 | [stats.Extent] > 0.9})) = 0;
filtro_regiao_filtrada(vertcat(mserConnComp.PixelIdxList{[stats.Solidity] < 0.3})) = 0;

figure, imshowpair(imagem_filtrada_dilatada, filtro_regiao_filtrada, 'montage');


%Stroke Width

region_image = stats(4).Image;
region_image = padarray(region_image, [1,1]);

distance_image = bwdist(~region_image);
skeleton_image = bwmorph(region_image, 'thin', inf);

strokeWidthImage = distance_image;
strokeWidthImage(~skeleton_image) = 0;

figure
subplot(1,2,1)
imagesc(region_image)
title('Region Image')

subplot(1,2,2)
imagesc(strokeWidthImage)
title('Stroke Width Image')


%Implementar Stroke Width na Imagem

strokeWidthValues = distance_image(skeleton_image);   
strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);

strokeWidthThreshold = 0.4;
strokeWidthFilterIdx = strokeWidthMetric > strokeWidthThreshold; 


for j = 1:numel(stats)
    
    region_image = stats(j).Image;
    region_image = padarray(region_image, [1 1], 0);
    
    distance_image = bwdist(~region_image);
    skeleton_image = bwmorph(region_image, 'thin', inf);
    
    strokeWidthValues = distance_image(skeleton_image);
    
    strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);
    
    strokeWidthFilterIdx(j) = strokeWidthMetric > strokeWidthThreshold;
    
end


mserRegions(strokeWidthFilterIdx) = [];
stats(strokeWidthFilterIdx) = [];


figure, imshow(imagemCinza)
hold on
plot(mserRegions, 'showPixelList', true,'showEllipses',false)
title('After Removing Non-Text Regions Based On Stroke Width Variation')
hold off


bboxes = vertcat(stats.BoundingBox);

% Convert from the [x y width height] bounding box format to the [xmin ymin
% xmax ymax] format for convenience.
xmin = bboxes(:,1);
ymin = bboxes(:,2);
xmax = xmin + bboxes(:,3) - 1;
ymax = ymin + bboxes(:,4) - 1;

expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
IExpandedBBoxes = insertShape(imagemColorida,'Rectangle',expandedBBoxes,'LineWidth',3);

figure
imshow(IExpandedBBoxes)
title('Expanded Bounding Boxes Text')


