%% 读出零鲁棒水印图像。

I_zero_robust_seal = imread('encryption/zero_robust_seal.bmp');

%% 读出零半脆弱水印图像。

I_semifragile_seal = imread('encryption/semifragile_seal.bmp');

%% 读出待检测图像，转换成YCbCr图像，并分解出Y*、Cb*、Cr*通道。

I_test = imread('img/lena.bmp');

Red = I_test(:,:,1);
Green = I_test(:,:,2);
Blue = I_test(:,:,3);

Y = 0.299*Red + 0.587*Green + 0.114*Blue;
Cb = -0.1687*Red - 0.3313*Green + 0.5*Blue + 128;
Cr = 0.5*Red - 0.4187*Green - 0.0813*Blue + 128;

% imshow(Y);
disp('RGB -> YCbCr');

%% 对待检测图像的Y*、Cb*、Cr*通道分别进行三尺度的“db1”离散小波变换，并进行奇异值分解。

[coefficient_subband(:,:,1), coefficient_subband(:,:,2), coefficient_subband(:,:,3), coefficient_subband(:,:,4)] = DWT(Y, 'db1');
[coefficient_subband(:,:,5), coefficient_subband(:,:,6), coefficient_subband(:,:,7), coefficient_subband(:,:,8)] = DWT(Cb, 'db1');
[coefficient_subband(:,:,9), coefficient_subband(:,:,10), coefficient_subband(:,:,11), coefficient_subband(:,:,12)] = DWT(Cr, 'db1');

disp('finish dwt');

for tmp = 1:12
    [USV(:,:,tmp), USV(:,:,tmp+12), USV(:,:,tmp+24)] = svd(coefficient_subband(:,:,tmp));
end

disp('finish svd');

%% 构造DCNN的输入矩阵和输出标签矩阵。

X = USV;

X_size = size(X);
for tmp = 1:36
    T(tmp) = sum(X(:,tmp,1)) / (X_size(1)*X_size(2));
end

%% 建立如图2所示的DCNN。对DCNN进行训练。
 % ！！【原文可能有bug，加载使用原图训练的网络直接预测比较合理】！！

trainingImages = reshape(USV, X_size(1), X_size(2), 1, []);
load('encryption/net.mat');

%% 构造用于提取鲁棒水印图像的信息矩阵。

F = activations(Net, trainingImages, 5);
% size(F); % [X, Y, num of filter in C2, num of image]

F = reshape(F, [], 36);

% ************************ F&G plan A ****************************%
% for i = 1:36
%     for j = 1:36
%         G(i, j) = sum(F((i-1)*100+(1:100), j))/100;
%         if F(i*50, j) > G(i, j)
%             G(i, j) = 1;
%         else
%             G(i, j) = 0;
%         end
%     end
% end

% ************************ F&G plan B ****************************%
% for j = 1:36
%     F_avg(j) = mean(F(1:100, j));
% end
% 
% for i = 1:36
%     for j = 1:36
%         if F(50, j) > F_avg(i)
%             G(i, j) = 1;
%         else
%             G(i, j) = 0;
%         end
%     end
% end

% ************************ F&G plan C ****************************%
for i = 1:36
    for j = 1:36
        G(i, j) = sum(F((i-1)*100+(1:100), j))/100;
        if F(50, j) < G(i, j)
            G(i, j) = 1;
        else
            G(i, j) = 0;
        end
    end
end

%% 提取鲁棒水印图像。
 % 将上一块获取的信息矩阵和零鲁棒水印进行异或运算，提取出置乱的鲁棒水印图像
 % 利用Arnold变换进行反置乱，则得到提取的鲁棒水印图像。

robust_seal = xor(G, I_zero_robust_seal);
a = 1;
b = 1;
N = 30;

I_robust_seal = arnold(robust_seal, a, b, N);
disp('decrypted robust seal');

%% 构造用于提取半脆弱水印图像的信息矩阵。

LL3 = coefficient_subband(:,:,1);
LL3_size = size(LL3);

for i = 0:LL3_size(1)-1
    for j = 0:LL3_size(2)-1
        if (LL3(i+1, j+1) >= LL3(mod(i+1, LL3_size(1))+1, j+1)) && ...
                (LL3(mod(i+1, LL3_size(1))+1, j+1) >= LL3(mod(i+2, LL3_size(1))+1, j+1))
            info(i+1, j+1) = 1;
        else
            info(i+1, j+1) = 0;
        end
    end
end

%% 提取半脆弱水印图像。
 % 将上一块得到的信息矩阵和零半脆弱水印进行异或运算，则得到提取的半脆弱水印图像。

semifragile_seal = xor(info, I_semifragile_seal);
disp('decrypted robust seal');

%% 保存相关图像
subplot(1, 2, 1);
imshow(mat2gray(I_robust_seal));
subplot(1, 2, 2);
imshow(mat2gray(semifragile_seal));

imwrite(mat2gray(I_robust_seal), 'decryption/robust_seal.bmp');
imwrite(mat2gray(semifragile_seal), 'decryption/semifragile_seal.bmp');

disp('Done!');