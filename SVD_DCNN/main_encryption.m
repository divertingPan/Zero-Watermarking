%% 对原始彩色图像进行转换。读出原始图像，将其转换为YCbCr图像，并分解出Y、Cb、Cr通道。

I_original = imread('img/lena.bmp');

Red = I_original(:,:,1);
Green = I_original(:,:,2);
Blue = I_original(:,:,3);

Y = 0.299*Red + 0.587*Green + 0.114*Blue;
Cb = -0.1687*Red - 0.3313*Green + 0.5*Blue + 128;
Cr = 0.5*Red - 0.4187*Green - 0.0813*Blue + 128;

% imshow(Y);
disp('RGB -> YCbCr');

%% 读出鲁棒水印图像，并利用Arnold变换进行置乱。

I_robust_seal = imread('img/E.bmp');
a = 1;
b = 1;
N = 30;

I_robust_seal_chaos = arnold(I_robust_seal, a, b, N);

% imshow(I_robust_seal_chaos);
disp('seal -> Arnold');

%% 读出半脆弱水印图像。

I_semifragile_seal = imread('img/seal.bmp');

% imshow(I_semifragile_seal);
disp('load semi-fragile seal');


%% 对原始图像的Y、Cb、Cr通道分别进行三尺度的“db1”离散小波变换，并进行奇异值分解。
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

disp('finish dwt');

% [U1,S1,V1] = svd(LL3);
% [U2,S2,V2] = svd(LLp3);
% [U3,S3,V3] = svd(LLpp3);
% [U4,S4,V4] = svd(LH3);
% [U5,S5,V5] = svd(LHp3);
% [U6,S6,V6] = svd(LHpp3);
% [U7,S7,V7] = svd(HL3);
% [U8,S8,V8] = svd(HLp3);
% [U9,S9,V9] = svd(HLpp3);
% [U10,S10,V10] = svd(HH3);
% [U11,S11,V11] = svd(HHp3);
% [U12,S12,V12] = svd(HHpp3);

for tmp = 1:12
    [USV(:,:,tmp), USV(:,:,tmp+12), USV(:,:,tmp+24)] = svd(coefficient_subband(:,:,tmp));
end

disp('finish svd');

%% 构造DCNN的输入矩阵和输出标签矩阵。将步骤4中得到的36个矩阵转换成尺度为偶数的方阵。
 % 将Y、Cb、Cr通道中得到的方阵尺度最大值赋值给m，创建m×m×36的特征矩阵X
 % 每个面为Xn(n=1,2,…,36)，将X1的前36列每列之和除以X1元素总个数，得1×36输出标签矩阵T

X = USV;

X_size = size(X);
for tmp = 1:36
    T(tmp) = sum(X(:,tmp,1)) / (X_size(1)*X_size(2));
end

%% 建立的DCNN如 CNN_graph 所示。
 % 卷积层（C1，C2）所用卷积核的尺寸都为5×5，C1输出18个矩阵，C2输出36个矩阵
 % 下采样层（S1，S2）矩阵尺寸降为原来的1/4。
 
CNN_Graph = [
    imageInputLayer([64 64 1],"Name","imageinput","Normalization","zerocenter")
    convolution2dLayer([5 5],18,"Name","conv_1")
    averagePooling2dLayer([2 2],"Name","avgpool2d_1","Padding","same","Stride",[2 2])
    convolution2dLayer([5 5],36,"Name","conv_2")
    averagePooling2dLayer([2 2],"Name","avgpool2d_2","Padding","same","Stride",[2 2])
    fullyConnectedLayer(128,"Name","fc_1")
    fullyConnectedLayer(64,"Name","fc_2")
    fullyConnectedLayer(36,"Name","fc_3")
    softmaxLayer("Name","softmax")
    classificationLayer("Name","classoutput")];

%% training的数据结构是 [X, Y, channel, num]
trainingImages = reshape(USV, X_size(1), X_size(2), 1, []);
trainingLabels = categorical(T);

opts = trainingOptions('adam', ...
        'LearnRateSchedule', 'none', ...
        'LearnRateDropFactor', 0.99, ...
        'LearnRateDropPeriod', 1, ...
        'MaxEpochs', 500, ...
        'MiniBatchSize', 36, ...
        'Plots','training-progress');

Net = trainNetwork(trainingImages, trainingLabels, CNN_Graph, opts);
save('encryption/net.mat', 'Net');
disp('weights saved');

%% 获取用于构造零鲁棒水印图像的信息矩阵。
 % 取出S2层输出的矩阵F，取F中每一个100行j列(j=1,2,…,36)为一组，记作第i组，计算其平均值。
 % 创建大小为36×36的矩阵G，如果F第50行j列的元素大于第i组元素平均值，则G的[i,j]元素为1，否则为0
 % 得到的G为用于构造零鲁棒水印的信息矩阵。

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

%% 构造零鲁棒水印图像。
 % 将上一块获得的G和原始鲁棒水印进行异或运算，则产生零鲁棒水印图像。

zero_robust_seal = xor(G, I_robust_seal_chaos);
disp('encrypted zero robust seal');
% imshow(zero_robust_seal);

%% 获取用于构造半脆弱水印图像的信息矩阵。
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

%% 构造零半脆弱水印图像。
 % 将信息矩阵和原始半脆弱水印进行异或运算，产生零半脆弱水印图像。

semifragile_seal = xor(info, I_semifragile_seal);
disp('encrypted semi-fragile seal');
% imshow(semifragile_seal);

%% 保存相关图像

imwrite(mat2gray(semifragile_seal), 'encryption/semifragile_seal.bmp');
imwrite(mat2gray(zero_robust_seal), 'encryption/zero_robust_seal.bmp');

disp('Done!');