function semifragile_seal = SVD_frag_decrypt(I_test, zero_semifragile_seal)
% 解密脆弱水印
I_test = imresize(I_test, [512,512]);
zero_semifragile_seal = imresize(zero_semifragile_seal, [64,64]);

Red = I_test(:,:,1);
Green = I_test(:,:,2);
Blue = I_test(:,:,3);

Y = 0.299*Red + 0.587*Green + 0.114*Blue;
Cb = -0.1687*Red - 0.3313*Green + 0.5*Blue + 128;
Cr = 0.5*Red - 0.4187*Green - 0.0813*Blue + 128;

% 对待检测图像的Y*、Cb*、Cr*通道分别进行三尺度的“db1”离散小波变换，并进行奇异值分解。

[coefficient_subband(:,:,1), coefficient_subband(:,:,2), coefficient_subband(:,:,3), coefficient_subband(:,:,4)] = DWT(Y, 'db1');
[coefficient_subband(:,:,5), coefficient_subband(:,:,6), coefficient_subband(:,:,7), coefficient_subband(:,:,8)] = DWT(Cb, 'db1');
[coefficient_subband(:,:,9), coefficient_subband(:,:,10), coefficient_subband(:,:,11), coefficient_subband(:,:,12)] = DWT(Cr, 'db1');

% 构造用于提取半脆弱水印图像的信息矩阵。

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

% 提取半脆弱水印图像。
 % 将上一块得到的信息矩阵和零半脆弱水印进行异或运算，则得到提取的半脆弱水印图像。

semifragile_seal = xor(info, zero_semifragile_seal);
semifragile_seal = mat2gray(semifragile_seal);
