%% ��ԭʼ��ɫͼ�����ת��������ԭʼͼ�񣬽���ת��ΪYCbCrͼ�񣬲��ֽ��Y��Cb��Crͨ����

I_original = imread('img/lena.bmp');

Red = I_original(:,:,1);
Green = I_original(:,:,2);
Blue = I_original(:,:,3);

Y = 0.299*Red + 0.587*Green + 0.114*Blue;
Cb = -0.1687*Red - 0.3313*Green + 0.5*Blue + 128;
Cr = 0.5*Red - 0.4187*Green - 0.0813*Blue + 128;

% imshow(Y);
disp('RGB -> YCbCr');

%% ����³��ˮӡͼ�񣬲�����Arnold�任�������ҡ�

I_robust_seal = imread('img/E.bmp');
a = 1;
b = 1;
N = 30;

I_robust_seal_chaos = arnold(I_robust_seal, a, b, N);

% imshow(I_robust_seal_chaos);
disp('seal -> Arnold');

%% ���������ˮӡͼ��

I_semifragile_seal = imread('img/seal.bmp');

% imshow(I_semifragile_seal);
disp('load semi-fragile seal');


%% ��ԭʼͼ���Y��Cb��Crͨ���ֱ�������߶ȵġ�db1����ɢС���任������������ֵ�ֽ⡣
 % Y��Cb��Crͨ��С���任���������Ӵ�С��ϵ������ֱ�Ϊ
 % LL3��HL3��LH3��HH3
 % LL'3��HL'3��LH'3��HH'3
 % LL''3��HL''3��LH''3��HH''3
 % ����12�������������ֵ�ֽ⣬���õ�36����ά����

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

%% ����DCNN���������������ǩ���󡣽�����4�еõ���36������ת���ɳ߶�Ϊż���ķ���
 % ��Y��Cb��Crͨ���еõ��ķ���߶����ֵ��ֵ��m������m��m��36����������X
 % ÿ����ΪXn(n=1,2,��,36)����X1��ǰ36��ÿ��֮�ͳ���X1Ԫ���ܸ�������1��36�����ǩ����T

X = USV;

X_size = size(X);
for tmp = 1:36
    T(tmp) = sum(X(:,tmp,1)) / (X_size(1)*X_size(2));
end

%% ������DCNN�� CNN_graph ��ʾ��
 % ����㣨C1��C2�����þ���˵ĳߴ綼Ϊ5��5��C1���18������C2���36������
 % �²����㣨S1��S2������ߴ罵Ϊԭ����1/4��
 
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

%% training�����ݽṹ�� [X, Y, channel, num]
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

%% ��ȡ���ڹ�����³��ˮӡͼ�����Ϣ����
 % ȡ��S2������ľ���F��ȡF��ÿһ��100��j��(j=1,2,��,36)Ϊһ�飬������i�飬������ƽ��ֵ��
 % ������СΪ36��36�ľ���G�����F��50��j�е�Ԫ�ش��ڵ�i��Ԫ��ƽ��ֵ����G��[i,j]Ԫ��Ϊ1������Ϊ0
 % �õ���GΪ���ڹ�����³��ˮӡ����Ϣ����

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

%% ������³��ˮӡͼ��
 % ����һ���õ�G��ԭʼ³��ˮӡ����������㣬�������³��ˮӡͼ��

zero_robust_seal = xor(G, I_robust_seal_chaos);
disp('encrypted zero robust seal');
% imshow(zero_robust_seal);

%% ��ȡ���ڹ�������ˮӡͼ�����Ϣ����
 % ��LL3(i,j) �� LL3((i+1),j) �� LL3((i+2),j)ʱ����Ϣ�����Ԫ��Ϊ1������Ϊ0
 
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

%% ����������ˮӡͼ��
 % ����Ϣ�����ԭʼ�����ˮӡ����������㣬����������ˮӡͼ��

semifragile_seal = xor(info, I_semifragile_seal);
disp('encrypted semi-fragile seal');
% imshow(semifragile_seal);

%% �������ͼ��

imwrite(mat2gray(semifragile_seal), 'encryption/semifragile_seal.bmp');
imwrite(mat2gray(zero_robust_seal), 'encryption/zero_robust_seal.bmp');

disp('Done!');