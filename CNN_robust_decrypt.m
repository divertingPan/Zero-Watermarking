function I_robust_seal = CNN_robust_decrypt(I_test, Net, I_zero_robust_seal)
% 解密鲁棒水印
I_test = imresize(I_test, [512,512]);
I_zero_robust_seal = imresize(I_zero_robust_seal, [36,36]);

% 读出待检测图像，转换成YCbCr图像，并分解出Y*、Cb*、Cr*通道。
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

for tmp = 1:12
    [USV(:,:,tmp), USV(:,:,tmp+12), USV(:,:,tmp+24)] = svd(coefficient_subband(:,:,tmp));
end

% 构造DCNN的输入矩阵和输出标签矩阵。
X = USV;

X_size = size(X);
for tmp = 1:36
    T(tmp) = sum(X(:,tmp,1)) / (X_size(1)*X_size(2));
end
% 加载使用原图训练的网络直接预测
trainingImages = reshape(USV, X_size(1), X_size(2), 1, []);

F = activations(Net, trainingImages, 5);

% 构造用于提取鲁棒水印图像的信息矩阵。
F = reshape(F, [], 36);

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

% 提取鲁棒水印图像。
 % 将上一块获取的信息矩阵和零鲁棒水印进行异或运算，提取出置乱的鲁棒水印图像
 % 利用Arnold变换进行反置乱，则得到提取的鲁棒水印图像。
robust_seal = xor(G, I_zero_robust_seal);
a = 1;
b = 1;
N = 30;

I_robust_seal = arnold(robust_seal, a, b, N);
I_robust_seal = mat2gray(I_robust_seal);
