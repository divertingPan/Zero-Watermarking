function [T] = TAF(wex, w)
% TAF   = Tamper Assesment function
% w     = Watermark Image
% wex   = Extracted watermark
% T     = TAF result

% Code Developed BY : Suraj Kamya
% kamyasuraj@yahoo.com


% w = imread('img/E.bmp');
% template = imread('encryption/zero_robust_seal.bmp');
% wex = imread('test/robust_seal_rotate0.3.bmp');

[r, c] = size(w); % Size of wmrk

w = mat2gray(w);
wex = mat2gray(wex); % Binary Conversion

exor = xor(w, wex); % Exclusive or 

T = sum(exor(:)) / (r*c); % TAF Computaion