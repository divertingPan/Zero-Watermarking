%% 读出零鲁棒水印图像。

I_zero_robust_seal = imread('encryption/zero_robust_seal.bmp');


%% 读出待检测图像。

I_test = imread('img/lena.bmp');

Red = I_test(:,:,1);
Green = I_test(:,:,2);
Blue = I_test(:,:,3);


%% 对待检测图像的R、G、B通道分别进行三尺度的“db1”离散小波变换，并进行奇异值分解。

[coefficient_subband(:,:,1), coefficient_subband(:,:,2), coefficient_subband(:,:,3), coefficient_subband(:,:,4)] = DWT(Red, 'db1');
[coefficient_subband(:,:,5), coefficient_subband(:,:,6), coefficient_subband(:,:,7), coefficient_subband(:,:,8)] = DWT(Green, 'db1');
[coefficient_subband(:,:,9), coefficient_subband(:,:,10), coefficient_subband(:,:,11), coefficient_subband(:,:,12)] = DWT(Blue, 'db1');

disp('finish dwt');

for tmp = 1:12
    [USV(:,:,tmp), USV(:,:,tmp+12), USV(:,:,tmp+24)] = svd(coefficient_subband(:,:,tmp));
end

disp('finish svd');

%% 构造QCNN的输入矩阵和输出标签矩阵。

X = USV;

X_size = size(X);
for tmp = 1:36
    T(tmp) = sum(X(:,tmp,1)) / (X_size(1)*X_size(2));
end

save('tmp/test_input.mat', 'X');

%% QCNN解密

[status, cmdout] = dos('QCNN_decrypt.bat');
if status == 0
    disp('predicting QCNN done!');
end
load('tmp/test_meddle_layer.mat');


%% 构造用于提取鲁棒水印图像的信息矩阵。

F = reshape(F, [], 36);

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

for j = 1:36
    F_avg(j) = mean(F(1:100, j));
end

for i = 1:36
    for j = 1:36
        if F(50, j) > F_avg(i)
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


%% 保存相关图像

imshow(I_robust_seal, []);
imwrite(mat2gray(I_robust_seal), 'decryption/robust_seal.bmp');
disp('Done!');
