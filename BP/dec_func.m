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

% *********************** 预测 ************************ %
% 随便产生一个图
% 在这里读取子图块，产生预测输出值，数据维度同上
image_predict = sub_img;

% 预处理输入
P_predict = reshape(image_predict, 9, []);

load('encryption/bp_net.mat');
output = sim(bp_net, P_predict);

% 构建B
for i = 1:1296
    if S(i) < output(i)
        B(i) = 0;
    else
        B(i) = 1;
    end
end

% B和水印异或，得到乱水印
B = reshape(B, 36, 36);
encrypt_seal = imread('encryption/bp_seal.bmp');
seal = xor(encrypt_seal, B);

a = 1;
b = 1;
N = 30;
seal = arnold(seal, a, b, N);
seal = mat2gray(seal);
