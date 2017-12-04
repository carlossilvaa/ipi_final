close all
clear all

for A = 1:61
    nome = strcat('BD/image(',int2str(A),').jpg');
    imagem_colorida = imread(nome);
    imagem_cinza = rgb2gray(imagem_colorida);


    [regioesMser, connect] = detectMSERFeatures(imagem_cinza, 'RegionAreaRange',[150 7000],'ThresholdDelta',4);

    %figure
    %imshow(imagem_cinza)
    %hold on
    %plot(regioesMser, 'showPixelList', true,'showEllipses',false)
    %title('MSER regions')
    %hold off

    stats = regionprops(connect, 'Area', 'Eccentricity', 'Solidity', 'Image', 'BoundingBox');

    filtro_regiao_filtrada = imagem_cinza;
    filtro_regiao_filtrada(vertcat(connect.PixelIdxList{[stats.Eccentricity] > 0.995})) = 0;
    filtro_regiao_filtrada(vertcat(connect.PixelIdxList{[stats.Area] < 150 | [stats.Area] > 10000})) = 0;
    filtro_regiao_filtrada(vertcat(connect.PixelIdxList{[stats.Solidity] < 0.3})) = 0;


    % Show remaining regions
    %figure
    %imshow(imagem_cinza)
    %hold on
    %plot(regioesMser, 'showPixelList', true,'showEllipses',false)
    %title('After Removing Non-Text Regions Based On Geometric Properties')
    %hold off


    % Get a binary image of the a region, and pad it to avoid boundary effects
    % during the stroke width computation.
    regioes = stats(4).Image;
    regioes = padarray(regioes, [1 1]);

    % Compute the stroke width image.
    distancia = bwdist(~regioes); 
    esqueleto = bwmorph(regioes, 'thin', inf);

    imagem_sw = distancia;
    imagem_sw(~esqueleto) = 0;

    % Compute the stroke width variation metric 
    valores_sw = distancia(esqueleto);   
    dados_sw = std(valores_sw)/mean(valores_sw);


    % Threshold the stroke width variation metric
    Threshold = 0.4;
    id_filtro_sw = dados_sw > Threshold; 


    % Process the remaining regions
    for j = 1:numel(stats)

        regioes = stats(j).Image;
        regioes = padarray(regioes, [1 1], 0);

        distancia = bwdist(~regioes);
        esqueleto = bwmorph(regioes, 'thin', inf);

        valores_sw = distancia(esqueleto);

        dados_sw = std(valores_sw)/mean(valores_sw);

        id_filtro_sw(j) = dados_sw > Threshold;

    end

    % Remove regions based on the stroke width variation
    regioesMser(id_filtro_sw) = [];
    stats(id_filtro_sw) = [];

    % Show remaining regions
    %figure
    %imshow(imagem_cinza)
    %hold on
    %plot(regioesMser, 'showPixelList', true,'showEllipses',false)
    %title('After Removing Non-Text Regions Based On Stroke Width Variation')
    %hold off

    % Get bounding boxes for all the regions
    segmento = vertcat(stats.BoundingBox);

    % Convert from the [x y width height] bounding box format to the [xmin ymin
    % xmax ymax] format for convenience.
    xmin = segmento(:,1);
    ymin = segmento(:,2);
    xmax = xmin + segmento(:,3) - 1;
    ymax = ymin + segmento(:,4) - 1;


    % Show the expanded bounding boxes
    segmento_letras = [xmin ymin xmax-xmin+1 ymax-ymin+1];
    segmento_letras = insertShape(imagem_colorida,'Rectangle',segmento_letras,'LineWidth',3);

    figure
    imshow(segmento_letras)
    title('Expanded Bounding Boxes Text')
end