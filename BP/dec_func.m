function seal = dec_func(I_original)

I_original = rgb2gray(I_original);
I_original = im2double(I_original);
[height, width] = size(I_original);
seperate_size_h = height / 36;
seperate_size_w = width / 36;

k = 1;
for i = 1:seperate_size_h:height
    for j = 1:seperate_size_w:width
        sub_img(:,:,k) = I_original((floor(i/seperate_size_h)*floor(seperate_size_h) + 1) : (floor(i/seperate_size_h)*floor(seperate_size_h) + 3), ...
                                    (floor(j/seperate_size_w)*floor(seperate_size_w) + 1) : (floor(j/seperate_size_w)*floor(seperate_size_w) + 3));
        k = k + 1;
    end
end

for i = 1:1296
    tmp = sub_img(:,:,i);
    S(i) = tmp(2, 2);
end

% *********************** Ԥ�� ************************ %
% ������һ��ͼ
% �������ȡ��ͼ�飬����Ԥ�����ֵ������ά��ͬ��
image_predict = sub_img;

% Ԥ��������
P_predict = reshape(image_predict, 9, []);

load('encryption/bp_net.mat');
output = sim(bp_net, P_predict);

% ����B
for i = 1:1296
    if S(i) < output(i)
        B(i) = 0;
    else
        B(i) = 1;
    end
end

% B��ˮӡ��򣬵õ���ˮӡ
B = reshape(B, 36, 36);
encrypt_seal = imread('encryption/bp_seal.bmp');
seal = xor(encrypt_seal, B);

a = 1;
b = 1;
N = 30;
seal = arnold(seal, a, b, N);
seal = mat2gray(seal);
