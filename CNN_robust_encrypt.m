function [zero_robust_seal, Net] = CNN_robust_encrypt(I_original, I_robust_seal)
% 鲁棒水印加密
I_original = imresize(I_original, [512,512]);
I_robust_seal = imresize(I_robust_seal, [36,36]);

% 对原始彩色图像进行转换。读出原始图像，将其转换为YCbCr图像，并分解出Y、Cb、Cr通道。
Red = I_original(:,:,1);
Green = I_original(:,:,2);
Blue = I_original(:,:,3);

Y = 0.299*Red + 0.587*Green + 0.114*Blue;
Cb = -0.1687*Red - 0.3313*Green + 0.5*Blue + 128;
Cr = 0.5*Red - 0.4187*Green - 0.0813*Blue + 128;

% 读出鲁棒水印图像，并利用Arnold变换进行置乱。
a = 1;
b = 1;
N = 30;

I_robust_seal_chaos = arnold(I_robust_seal, a, b, N);

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

for tmp = 1:12
    [USV(:,:,tmp), USV(:,:,tmp+12), USV(:,:,tmp+24)] = svd(coefficient_subband(:,:,tmp));
end

% 构造DCNN的输入矩阵和输出标签矩阵。将步骤4中得到的36个矩阵转换成尺度为偶数的方阵。
 % 将Y、Cb、Cr通道中得到的方阵尺度最大值赋值给m，创建m×m×36的特征矩阵X
 % 每个面为Xn(n=1,2,…,36)，将X1的前36列每列之和除以X1元素总个数，得1×36输出标签矩阵T
X = USV;

X_size = size(X);
for tmp = 1:36
    T(tmp) = sum(X(:,tmp,1)) / (X_size(1)*X_size(2));
end

% 建立的DCNN如 CNN_graph 所示。
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

% training的数据结构是 [X, Y, channel, num]
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

% 获取用于构造零鲁棒水印图像的信息矩阵。
 % 取出S2层输出的矩阵F，取F中每一个100行j列(j=1,2,…,36)为一组，记作第i组，计算其平均值。
 % 创建大小为36×36的矩阵G，如果F第50行j列的元素大于第i组元素平均值，则G的[i,j]元素为1，否则为0
 % 得到的G为用于构造零鲁棒水印的信息矩阵。
F = activations(Net, trainingImages, 5);

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

% 构造零鲁棒水印图像。
 % 将上一块获得的G和原始鲁棒水印进行异或运算，则产生零鲁棒水印图像。
zero_robust_seal = xor(G, I_robust_seal_chaos);
zero_robust_seal = mat2gray(zero_robust_seal);

