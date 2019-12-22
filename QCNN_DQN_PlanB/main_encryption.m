%% ����³��ˮӡͼ�񣬲�����Arnold�任�������ҡ�

I_robust_seal = imread('img/E.bmp');
a = 1;
b = 1;
N = 30;

I_robust_seal_chaos = arnold(I_robust_seal, a, b, N);

% imshow(I_robust_seal_chaos, []);
disp('seal -> Arnold');

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


%% ��36��R��G��Bͨ���ֱ�������߶ȵġ�db1����ɢС���任������������ֵ�ֽ⡣
% USV_size = [ 36, 7, 7, 36 ] (batch, h, w, tmp)

for batch = 1:36
    Red = sub_img(batch,:,:,1);
    Green = sub_img(batch,:,:,2);
    Blue = sub_img(batch,:,:,3);
    
    Red = reshape(Red, 56, 56);
    Green = reshape(Green, 56, 56);
    Blue = reshape(Blue, 56, 56);
    
    [coefficient_subband(batch,:,:,1), coefficient_subband(batch,:,:,2), coefficient_subband(batch,:,:,3), coefficient_subband(batch,:,:,4)] = DWT(Red, 'db1');
    [coefficient_subband(batch,:,:,5), coefficient_subband(batch,:,:,6), coefficient_subband(batch,:,:,7), coefficient_subband(batch,:,:,8)] = DWT(Green, 'db1');
    [coefficient_subband(batch,:,:,9), coefficient_subband(batch,:,:,10), coefficient_subband(batch,:,:,11), coefficient_subband(batch,:,:,12)] = DWT(Blue, 'db1');
end

for batch = 1:36
    for tmp = 1:12
        [USV(batch,:,:,tmp), USV(batch,:,:,tmp+12), USV(batch,:,:,tmp+24)] = svd(reshape(coefficient_subband(batch,:,:,tmp), 7, 7));
    end
end

disp('finish svd');

%% �����������ͱ�ǩ����
 % T_size = [ 36, 36 ] (batch, tmp)

for batch = 1:36
    for tmp = 1:36
        T(batch, tmp) = mean2(USV(batch,:,:,tmp));
    end
end

T = mapminmax(T, 0, 1);

save('tmp/input.mat', 'sub_img');
save('tmp/label.mat', 'T');


%% ����QCNN����

[status, cmdout] = dos('QCNN_encrypt.bat');
if status == 0
    disp('training QCNN done!');
end

load('tmp/meddle_layer.mat');
% size(F); % [X, Y, num of filter in C2, num of image]

%% ��ȡ���ڹ�����³��ˮӡͼ�����Ϣ����
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


%% ������³��ˮӡͼ��
 % ����һ���õ�G��ԭʼ³��ˮӡ����������㣬�������³��ˮӡͼ��

zero_robust_seal = xor(G, I_robust_seal_chaos);
disp('encrypted zero robust seal');


%% �������ͼ��

imshow(zero_robust_seal, []);
imwrite(mat2gray(zero_robust_seal), 'encryption/zero_robust_seal.bmp');

disp('Done!');