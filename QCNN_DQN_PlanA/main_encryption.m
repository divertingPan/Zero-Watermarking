%% ��ȡR��G��Bͨ����

I_original = imread('img/lena.bmp');

Red = I_original(:,:,1);
Green = I_original(:,:,2);
Blue = I_original(:,:,3);


%% ����³��ˮӡͼ�񣬲�����Arnold�任�������ҡ�

I_robust_seal = imread('img/E.bmp');
a = 1;
b = 1;
N = 30;

I_robust_seal_chaos = arnold(I_robust_seal, a, b, N);

% imshow(I_robust_seal_chaos, []);
disp('seal -> Arnold');


%% ��R��G��Bͨ���ֱ�������߶ȵġ�db1����ɢС���任������������ֵ�ֽ⡣
 % R��G��Bͨ��С���任���������Ӵ�С��ϵ������ֱ�Ϊ
 % LL3��HL3��LH3��HH3
 % LL'3��HL'3��LH'3��HH'3
 % LL''3��HL''3��LH''3��HH''3
 % ����12�������������ֵ�ֽ⣬���õ�36����ά����

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

%% �����������ͱ�ǩ���󡣽�����4�еõ���36������ת���ɳ߶�Ϊż���ķ���
 % ����64��64��36����������X
 % ÿ����ΪXn(n=1,2,��,36)����X1��ǰ36��ÿ��֮�ͳ���X1Ԫ���ܸ�������1��36�����ǩ����T

X = USV;

X_size = size(X);
for tmp = 1:36
    T(tmp) = sum(X(:,tmp,1)) / (X_size(1)*X_size(2));
end

save('tmp/input.mat', 'X');
save('tmp/label.mat', 'T');


%% ����QCNN����
 % ��python�����粢��ѵ����ȡ����F
 % ѵ���ú󱣴�.h5�ļ������ܵ�ʱ�������
 % todo = ['����python�ļ�', 'python��������pooling������Ľ�������.mat�ļ�', '��ȡ��F'];

% ��activateǰ���call������
% activate������Ҳ�Ǹ�bat�ű�����������ʵ����bat������һ��bat���µ�һ��bat�жϵ�����
[status, cmdout] = dos('QCNN_encrypt.bat');
if status == 0
    disp('training QCNN done!');
end

load('tmp/meddle_layer.mat');
% size(F); % [X, Y, num of filter in C2, num of image]

%% ��ȡ���ڹ�����³��ˮӡͼ�����Ϣ����
 % ȡ��S2������ľ���F��ȡF��ÿһ��100��j��(j=1,2,��,36)Ϊһ�飬������i�飬������ƽ��ֵ��
 % ������СΪ36��36�ľ���G�����F��50��j�е�Ԫ�ش��ڵ�i��Ԫ��ƽ��ֵ����G��[i,j]Ԫ��Ϊ1������Ϊ0
 % �õ���GΪ���ڹ�����³��ˮӡ����Ϣ����

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

%% ������³��ˮӡͼ��
 % ����һ���õ�G��ԭʼ³��ˮӡ����������㣬�������³��ˮӡͼ��

zero_robust_seal = xor(G, I_robust_seal_chaos);
disp('encrypted zero robust seal');
% imshow(zero_robust_seal);


%% �������ͼ��

imwrite(mat2gray(zero_robust_seal), 'encryption/zero_robust_seal.bmp');

disp('Done!');