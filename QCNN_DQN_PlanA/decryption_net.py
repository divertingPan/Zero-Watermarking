import keras
from keras.models import Model
from keras.models import Sequential
from keras.layers import Dense, AveragePooling2D, Flatten, Input, Activation, Convolution2D, concatenate
from quaternion_layers.conv import QuaternionConv2D
from keras.preprocessing.image import ImageDataGenerator
import scipy.io as scio
import numpy as np
 

batch_size = 36
num_classes = 36
epochs = 50

# input image dimensions
img_rows, img_cols = 64, 64
input_shape = (img_rows, img_cols, 1)

x_data = scio.loadmat('tmp/test_input.mat')
x_data = x_data['X']
x_data = x_data.astype('float32')

# reshape x_test
x_data = np.swapaxes(x_data, 0, -1)
x_test = np.expand_dims(x_data, axis=-1)

datagen = ImageDataGenerator(
    featurewise_center=True,
    featurewise_std_normalization=True)

datagen.fit(x_test)


def learnVectorBlock(I):
    """Learn initial vector component for input."""
    O = Convolution2D(1, (5, 5), padding='same', activation='relu')(I)
    return O

R = Input(shape=input_shape)
I = learnVectorBlock(R)
J = learnVectorBlock(R)
K = learnVectorBlock(R)
O = concatenate([R, I, J, K], axis=-1)
O = QuaternionConv2D(7, (5, 5), activation='relu', padding="same", kernel_initializer='quaternion')(O)
O = AveragePooling2D(pool_size=(2, 2), strides=(2, 2), padding="same")(O)
O = QuaternionConv2D(9, (5, 5), activation='relu', padding="same", kernel_initializer='quaternion')(O)
F = AveragePooling2D(pool_size=(2, 2), strides=(2, 2), padding="same")(O)

O = Flatten()(F)
O = Dense(128)(O)
O = Dense(64)(O)
O = Dense(num_classes, activation='softmax')(O)

model = Model(R, O)

# load the weights
model.load_weights('encryption/model.h5')

# get the metrix of meddle layer
model = Model(inputs=model.input, outputs=model.layers[8].output)
med_output = model.predict(x_test)

scio.savemat('tmp/test_meddle_layer.mat', {'F':med_output})
