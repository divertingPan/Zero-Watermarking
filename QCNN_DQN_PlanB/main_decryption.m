%% ������³��ˮӡͼ��

I_zero_robust_seal = imread('encryption/zero_robust_seal.bmp');

%% ��ȡ������ͼƬ���и�.
% sub_img_size = [ 36, 56, 56, 3 ] (batch, h, w, channel)

I_original = imread('img/lena.bmp');

[height, width, channel] = size(I_original);
seperate_size_h = height / 6;
seperate_size_w = width / 6;

batch = 1;
for i = 1:seperate_size_h:height
    for j = 1:seperate_size_w:width
        sub_img(batch,:,:,:) = I_original((floor(i/seperate_size_h)*floor(seperate_size_h) + 1) : (floor(i/seperate_size_h)*floor(seperate_size_h) + 56), ...
                                      (floor(j/seperate_size_w)*floor(seperate_size_w) + 1) : (floor(j/seperate_size_w)*floor(seperate_size_w) + 56), ...
                                      :);
        batch = batch + 1;
    end
end


%% ����QCNN���������

X = sub_img;

save('tmp/test_input.mat', 'X');

%% QCNN����

[status, cmdout] = dos('QCNN_decrypt.bat');
if status == 0
    disp('predicting QCNN done!');
end
load('tmp/test_meddle_layer.mat');


%% ��ȡ��Ϣ����
% F_size = [ 36, 7, 7, 36 ] (batch, h, w, tmp)

for batch = 1:36
    for tmp = 1:36
        center = F(batch, 4, 4, tmp);
        ave = mean2(reshape(F(batch, :,:,tmp), 7, 7));
        if center > ave
            G(batch, tmp) = 0;
        else
            G(batch, tmp) = 1;
        end
    end
end

%% ��ȡ³��ˮӡͼ��
 % ����һ���ȡ����Ϣ�������³��ˮӡ����������㣬��ȡ�����ҵ�³��ˮӡͼ��
 % ����Arnold�任���з����ң���õ���ȡ��³��ˮӡͼ��

robust_seal = xor(G, I_zero_robust_seal);
a = 1;
b = 1;
N = 30;

I_robust_seal = arnold(robust_seal, a, b, N);
disp('decrypted robust seal');


%% �������ͼ��

imshow(I_robust_seal, []);
imwrite(mat2gray(I_robust_seal), 'decryption/robust_seal.bmp');
disp('Done!');
