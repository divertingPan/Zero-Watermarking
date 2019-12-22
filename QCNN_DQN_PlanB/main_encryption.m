%% 读出鲁棒水印图像，并利用Arnold变换进行置乱。

I_robust_seal = imread('img/E.bmp');
a = 1;
b = 1;
N = 30;

I_robust_seal_chaos = arnold(I_robust_seal, a, b, N);

% imshow(I_robust_seal_chaos, []);
disp('seal -> Arnold');

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


%% 对36个R、G、B通道分别进行三尺度的“db1”离散小波变换，并进行奇异值分解。
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

%% 构造输入矩阵和标签矩阵。
 % T_size = [ 36, 36 ] (batch, tmp)

for batch = 1:36
    for tmp = 1:36
        T(batch, tmp) = mean2(USV(batch,:,:,tmp));
    end
end

T = mapminmax(T, 0, 1);

save('tmp/input.mat', 'sub_img');
save('tmp/label.mat', 'T');


%% 建立QCNN网络

[status, cmdout] = dos('QCNN_encrypt.bat');
if status == 0
    disp('training QCNN done!');
end

load('tmp/meddle_layer.mat');
% size(F); % [X, Y, num of filter in C2, num of image]

%% 获取用于构造零鲁棒水印图像的信息矩阵。
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


%% 构造零鲁棒水印图像。
 % 将上一块获得的G和原始鲁棒水印进行异或运算，则产生零鲁棒水印图像。

zero_robust_seal = xor(G, I_robust_seal_chaos);
disp('encrypted zero robust seal');


%% 保存相关图像

imshow(zero_robust_seal, []);
imwrite(mat2gray(zero_robust_seal), 'encryption/zero_robust_seal.bmp');

disp('Done!');