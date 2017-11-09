clear all;
close all;
clc;

ms = imread("microsoft.png");
ms_gray = rgb2gray(ms);
ms_bw = edge(ms_gray, 'canny');

imshow(ms_bw);