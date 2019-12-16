image = imread('decryption/robust_seal.bmp');
template = imread('img/E.bmp');

[T] = TAF(image, template)