% 用此模块对图像作攻击，获得测试用例

%% 读取
I_original = imread('img/lena.bmp');


%% 旋转
I_rotate(:,:,:,1) = I_original;
for t = 1:10
    tmp = imrotate(I_original, 5*t, 'bilinear', 'crop');
    imwrite(tmp, ['test/lena_rotate', num2str(5*t), '.bmp']);
    I_rotate(:,:,:,t+1) = tmp;
end


%% 高斯噪声
I_gaussian(:,:,:,1) = I_original;
for t = 1:10
    tmp = imnoise(I_original, 'gaussian', 0, 0.1*t);
    imwrite(tmp, ['test/lena_gaussian', num2str(0.1*t), '.bmp']);
    I_gaussian(:,:,:,t+1) = tmp;
end


%% 椒盐噪声
I_saltpepper(:,:,:,1) = I_original;
for t = 1:10
    tmp = imnoise(I_original, 'salt & pepper', 0.1*t);
    imwrite(tmp, ['test/lena_saltpepper', num2str(0.1*t), '.bmp']);
    I_saltpepper(:,:,:,t+1) = tmp;
end


%% 中值滤波
I_medfilt(:,:,:,1) = I_original;
for t = 1:10
    for i = 1:3
        tmp(:,:,i) = medfilt2(I_original(:,:,i), [10*t, 10*t]);
    end
    imwrite(tmp, ['test/lena_medfilt', num2str(10*t), '.bmp']);
    I_medfilt(:,:,:,t+1) = tmp;
end


%% JPEG压缩
I_compressed(:,:,:,1) = I_original;
for t = 1:10
    imwrite(I_original, ['test/lena_compressed', num2str(10*t), '.jpg'], 'Quality', 10*t);
    I_compressed(:,:,:,t+1) = imread(['img/lena_compressed', num2str(10*t), '.jpg']);
end


%% 拼贴1
I_paste1(:,:,:,1) = I_original;
s = size(I_original);
w = s(1) - mod(s(1), 10);
h = s(2);
tmp = I_original;
for t = 1:10
    tmp2 = tmp(w/10*(t-1)+1:w/10*t, w/2+1:w, :);
    tmp(w/10*(t-1)+1:w/10*t, w/2+1:w, :) = tmp(w/10*(t-1)+1:w/10*t, 1:w/2, :);
    tmp(w/10*(t-1)+1:w/10*t, 1:w/2, :) = tmp2;
    I_paste1(:,:,:,t+1) = tmp;
    imwrite(tmp, ['test/lena_paste1_', num2str(t), '0.bmp']);
end


%% 拼贴2
I_paste2(:,:,:,1) = I_original;
I_source = imread('img/peppers.png');
s = size(I_original);
w = s(1) - mod(s(1), 10);
h = s(2);
tmp = I_original;
for t = 1:10
    tmp(w/10*(t-1)+1:w/10*t, :, :) = I_source(w/10*(t-1)+1:w/10*t, :, :);
    I_paste2(:,:,:,t+1) = tmp;
    imwrite(tmp, ['test/lena_paste2_', num2str(t), '0.bmp']);
end
