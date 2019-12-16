image = imread('decryption/robust_seal.bmp');
template = imread('img/E.bmp');

C = nc(image, template)