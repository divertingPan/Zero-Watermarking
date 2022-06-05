function [seal, bp_net] = BP_robust_encrypt(I_original, I_robust_seal)
% 构造鲁棒水印
I_original = imresize(I_original, [512,512]);
I_robust_seal = imresize(I_robust_seal, [36,36]);

% 读出鲁棒水印图像，并利用Arnold变换进行置乱。
a = 1;
b = 1;
N = 30;

I_robust_seal_chaos = arnold(I_robust_seal, a, b, N);

% 读取待加密图片，切割，取子图的中值和平均值
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
    Ave(i) = mean2(tmp);
end

% BP网络部分
% *********************** 训练 ************************ %
T = Ave;

% 直接在这里读取3x3的子图块即可，多个子图需要在第三轴上拼起来
image = sub_img;

% 预处理输入
P = reshape(image, 9, []);

% 构建网络结构
bp_net = newff(P, T, 50);

bp_net.trainParam.goal = 0;
bp_net.trainParam.epochs = 10000;
bp_net.trainParam.mc = 0.95;
bp_net.trainParam.lr = 0.05;
bp_net.trainParam.min_grad = 0;
bp_net.trainParam.showWindow = 1;
bp_net.divideFcn = '';

bp_net = train(bp_net, P, T);
% save('encryption/bp_net.mat', 'bp_net');

% 构建B，异或运算得到水印
for i = 1:1296
    if S(i) < Ave(i)
        B(i) = 0;
    else
        B(i) = 1;
    end
end

B = reshape(B, 36, 36);
seal = xor(I_robust_seal_chaos, B);
seal = mat2gray(seal);
% imwrite(mat2gray(seal), 'encryption/bp_seal.bmp');
% imshow(seal, []);