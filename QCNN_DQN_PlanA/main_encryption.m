%% 提取R、G、B通道。

I_original = imread('img/lena.bmp');

Red = I_original(:,:,1);
Green = I_original(:,:,2);
Blue = I_original(:,:,3);


%% 读出鲁棒水印图像，并利用Arnold变换进行置乱。

I_robust_seal = imread('img/E.bmp');
a = 1;
b = 1;
N = 30;

I_robust_seal_chaos = arnold(I_robust_seal, a, b, N);

% imshow(I_robust_seal_chaos, []);
disp('seal -> Arnold');


%% 对R、G、B通道分别进行三尺度的“db1”离散小波变换，并进行奇异值分解。
 % R、G、B通道小波变换后第三层的子带小波系数矩阵分别为
 % LL3，HL3，LH3，HH3
 % LL'3，HL'3，LH'3，HH'3
 % LL''3，HL''3，LH''3，HH''3
 % 对这12个矩阵进行奇异值分解，共得到36个二维矩阵。

% [LL3, LH3, HL3, HH3] = DWT(R, 'db1');
% [LLp3, LHp3, HLp3, HHp3] = DWT(G, 'db1');
% [LLpp3, LHpp3, HLpp3, HHpp3] = DWT(B, 'db1');

[coefficient_subband(:,:,1), coefficient_subband(:,:,2), coefficient_subband(:,:,3), coefficient_subband(:,:,4)] = DWT(Red, 'db1');
[coefficient_subband(:,:,5), coefficient_subband(:,:,6), coefficient_subband(:,:,7), coefficient_subband(:,:,8)] = DWT(Green, 'db1');
[coefficient_subband(:,:,9), coefficient_subband(:,:,10), coefficient_subband(:,:,11), coefficient_subband(:,:,12)] = DWT(Blue, 'db1');

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

%% 构造输入矩阵和标签矩阵。将步骤4中得到的36个矩阵转换成尺度为偶数的方阵。
 % 创建64×64×36的特征矩阵X
 % 每个面为Xn(n=1,2,…,36)，将X1的前36列每列之和除以X1元素总个数，得1×36输出标签矩阵T

X = USV;

X_size = size(X);
for tmp = 1:36
    T(tmp) = sum(X(:,tmp,1)) / (X_size(1)*X_size(2));
end

save('tmp/input.mat', 'X');
save('tmp/label.mat', 'T');


%% 建立QCNN网络
 % 用python搭网络并且训练，取出来F
 % 训练好后保存.h5文件，解密的时候加载用
 % todo = ['调用python文件', 'python里存下最后pooling层输出的结果，存成.mat文件', '读取给F'];

% 在activate前面加call就行了
% activate本质上也是个bat脚本，本问题其实就是bat调用另一个bat导致第一个bat中断的问题
[status, cmdout] = dos('QCNN_encrypt.bat');
if status == 0
    disp('training QCNN done!');
end

load('tmp/meddle_layer.mat');
% size(F); % [X, Y, num of filter in C2, num of image]

%% 获取用于构造零鲁棒水印图像的信息矩阵。
 % 取出S2层输出的矩阵F，取F中每一个100行j列(j=1,2,…,36)为一组，记作第i组，计算其平均值。
 % 创建大小为36×36的矩阵G，如果F第50行j列的元素大于第i组元素平均值，则G的[i,j]元素为1，否则为0
 % 得到的G为用于构造零鲁棒水印的信息矩阵。

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

%% 构造零鲁棒水印图像。
 % 将上一块获得的G和原始鲁棒水印进行异或运算，则产生零鲁棒水印图像。

zero_robust_seal = xor(G, I_robust_seal_chaos);
disp('encrypted zero robust seal');
% imshow(zero_robust_seal);


%% 保存相关图像

imwrite(mat2gray(zero_robust_seal), 'encryption/zero_robust_seal.bmp');

disp('Done!');