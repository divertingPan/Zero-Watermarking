function NC = nc(template, image)


[t_height, t_width] = size(template);
[i_height, i_width] = size(image);
h = min(t_height, i_height);
w = min(t_width, i_width);
template = imresize(template, [h,w]);
image = imresize(image, [h,w]);

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
