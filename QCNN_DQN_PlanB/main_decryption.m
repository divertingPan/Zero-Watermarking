%% 读出零鲁棒水印图像。

I_zero_robust_seal = imread('encryption/zero_robust_seal.bmp');

%% 读取待加密图片，切割.
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


%% 构造QCNN的输入矩阵。

X = sub_img;

save('tmp/test_input.mat', 'X');

%% QCNN解密

[status, cmdout] = dos('QCNN_decrypt.bat');
if status == 0
    disp('predicting QCNN done!');
end
load('tmp/test_meddle_layer.mat');


%% 获取信息矩阵。
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

%% 提取鲁棒水印图像。
 % 将上一块获取的信息矩阵和零鲁棒水印进行异或运算，提取出置乱的鲁棒水印图像
 % 利用Arnold变换进行反置乱，则得到提取的鲁棒水印图像。

robust_seal = xor(G, I_zero_robust_seal);
a = 1;
b = 1;
N = 30;

I_robust_seal = arnold(robust_seal, a, b, N);
disp('decrypted robust seal');


%% 保存相关图像

imshow(I_robust_seal, []);
imwrite(mat2gray(I_robust_seal), 'decryption/robust_seal.bmp');
disp('Done!');
