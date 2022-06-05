function semifragile_seal = SVD_frag_encrypt(I_original, I_semifragile_seal)
% 加密脆弱水印
I_original = imresize(I_original, [512,512]);
I_semifragile_seal = imresize(I_semifragile_seal, [64,64]);

% 对原始彩色图像进行转换。读出原始图像，将其转换为YCbCr图像，并分解出Y、Cb、Cr通道。

Red = I_original(:,:,1);
Green = I_original(:,:,2);
Blue = I_original(:,:,3);

Y = 0.299*Red + 0.587*Green + 0.114*Blue;
Cb = -0.1687*Red - 0.3313*Green + 0.5*Blue + 128;
Cr = 0.5*Red - 0.4187*Green - 0.0813*Blue + 128;

% 对原始图像的Y、Cb、Cr通道分别进行三尺度的“db1”离散小波变换，并进行奇异值分解。
 % Y、Cb、Cr通道小波变换后第三层的子带小波系数矩阵分别为
 % LL3，HL3，LH3，HH3
 % LL'3，HL'3，LH'3，HH'3
 % LL''3，HL''3，LH''3，HH''3
 % 对这12个矩阵进行奇异值分解，共得到36个二维矩阵。

% [LL3, LH3, HL3, HH3] = DWT(Y, 'db1');
% [LLp3, LHp3, HLp3, HHp3] = DWT(Cb, 'db1');
% [LLpp3, LHpp3, HLpp3, HHpp3] = DWT(Cr, 'db1');

[coefficient_subband(:,:,1), coefficient_subband(:,:,2), coefficient_subband(:,:,3), coefficient_subband(:,:,4)] = DWT(Y, 'db1');
[coefficient_subband(:,:,5), coefficient_subband(:,:,6), coefficient_subband(:,:,7), coefficient_subband(:,:,8)] = DWT(Cb, 'db1');
[coefficient_subband(:,:,9), coefficient_subband(:,:,10), coefficient_subband(:,:,11), coefficient_subband(:,:,12)] = DWT(Cr, 'db1');

% 获取用于构造半脆弱水印图像的信息矩阵。
 % 当LL3(i,j) ≥ LL3((i+1),j) ≥ LL3((i+2),j)时，信息矩阵的元素为1，否则为0
 
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

% 构造零半脆弱水印图像。
 % 将信息矩阵和原始半脆弱水印进行异或运算，产生零半脆弱水印图像。

semifragile_seal = xor(info, I_semifragile_seal);
semifragile_seal = mat2gray(semifragile_seal);

