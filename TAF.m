function taf = TAF(watermark_1, watermark_2)

[height_1, width_1] = size(watermark_1);
[height_2, width_2] = size(watermark_2);
height = min(height_1, height_2);
width = min(width_1, width_2);

watermark_1 = imresize(watermark_1, [height,width]);
watermark_2 = imresize(watermark_2, [height,width]);

tmp = xor(watermark_2, watermark_1);

taf = mean(tmp(:));