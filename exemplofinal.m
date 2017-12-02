clear all;
close all;


imagemColorida = imread('image(41).jpg');
imagemCinza = rgb2gray(imagemColorida);
figure, imshow(imagemCinza);

[mserRegions, mserConnComp] = detectMSERFeatures(imagemCinza, 'RegionAreaRange',[100 1000],'ThresholdDelta',4);
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

filtragemCanny = edge(imagemCinza,'Canny');
filtragemCanny = double(filtragemCanny);
figure, imshow(filtragemCanny);

mserFiltro = false(size(imagemCinza));
ind = sub2ind(size(mserFiltro), mserRegionsPixels(:, 2), mserRegionsPixels(:,1));
mserFiltro(ind) = true;

edgeMask = edge(imagemCinza, 'Canny');

imagem_filtrada = mserFiltro & edgeMask;
figure, imshow(imagem_filtrada);









