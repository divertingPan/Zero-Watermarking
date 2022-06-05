function encrypt_seal = Bit_frag_encrypt(image, seal)

image = rgb2gray(image);
image = double(imresize(image, [256,256]));
seal = double(imresize(seal, [256,256]));
seal = seal*255;

image_block = zeros(8,8);
seal_block = zeros(8,8);
image_block_bin = zeros(8,8,8);
seal_block_bin = zeros(8,8,8);
encrypt_seal = zeros(256, 256);

% 1.得到子区块
for i = 1:32
    for j = 1:32
        image_block = image(i*8-7:i*8, j*8-7:j*8);
        seal_block = seal(i*8-7:i*8, j*8-7:j*8);
        
        % 2.转成比特平面区块
        for si = 1:8
            for sj = 1:8
                image_block_bin(si, sj, :) = bitget(image_block(si, sj), 8:-1:1);
                seal_block_bin(si, sj, :) = bitget(seal_block(si, sj), 8:-1:1);
            end
        end
        
        % 3.旋转区块方向
        image_block_bin = permute(image_block_bin, [1,3,2]);
        seal_block_bin = permute(seal_block_bin, [1,3,2]);
        
        % 4.恢复成图像区块
        image_value_temp = 0;
        seal_value_temp = 0;
        for si = 1:8
            for sj = 1:8
                for sk = 1:8
                    image_block(si, sj) = image_value_temp + image_block_bin(si, sk, sj) * (2^(8-sk));
                    seal_block(si, sj) = seal_value_temp + seal_block_bin(si, sk, sj) * (2^(8-sk));
                end
            end
        end
        
        % 5.XOR两个区块
        encrypt_seal(i*8-7:i*8, j*8-7:j*8) = xor(image_block, seal_block);
        
    end
end