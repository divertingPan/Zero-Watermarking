function NC = nc(image, template)

% image = imread('encryption/zero_robust_seal.bmp');
% template = imread('encryption/zero_robust_seal.bmp');
% template = imread('test/robust_seal_rotate30.bmp');

image = mat2gray(image);
template = mat2gray(template);
[mimage, nimage] = size(image);
a = 0;
b = 0;
c = 0;

for i = 1:mimage
    for j = 1:nimage
        a = a + (image(i, j) * template(i, j));
        b = b + image(i, j) * image(i, j);
        c = c + template(i, j) * template(i, j);
    end
end

NC = a / (sqrt(b) * sqrt(c));

% 
% 
% [mimage, nimage] = size(image);
% [mtemplate, ntemplate] = size(template);
% NC = zeros(mimage - mtemplate + 1, nimage - ntemplate + 1);
% for u = 1:mimage - mtemplate + 1
%     for v = 1:nimage - ntemplate + 1
%         a = 0;
%         b = 0;
%         c = 0;
%         for i = 1:mtemplate
%             for j = 1:ntemplate
%                 a = a + image(i+u-1, j+v-1) * template(i, j);
%                 b = b + image(i+u-1, j+v-1) * image(i+u-1, j+v-1);
%                 c = c + template(i, j) * template(i, j);
%             end
%         end
%         b = sqrt(b);
%         c = sqrt(c);
%         NC(u, v) = a/(b*c);
%     end
% end