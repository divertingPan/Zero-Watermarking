import keras
from keras.models import Model
from keras.models import Sequential
from keras.layers import Dense, AveragePooling2D, Flatten, Input, Activation, Convolution2D, concatenate
from quaternion_layers.conv import QuaternionConv2D
from quaternion_layers.bn import QuaternionBatchNormalization
from keras.preprocessing.image import ImageDataGenerator
import scipy.io as scio
import numpy as np
 

num_classes = 36

# input image dimensions
img_rows, img_cols = 56, 56
input_shape = (img_rows, img_cols, 3)

x_data = scio.loadmat('tmp/test_input.mat')
x_data = x_data['X']
x_test = x_data.astype('float32')

datagen = ImageDataGenerator(
    featurewise_center=True,
    featurewise_std_normalization=True)

datagen.fit(x_test)


def learnVectorBlock(I):
    """Learn initial vector component for input."""
    O = Convolution2D(3, (5, 5), padding='same', activation='relu')(I)
    return O

R = Input(shape=input_shape)
I = learnVectorBlock(R)
J = learnVectorBlock(R)
K = learnVectorBlock(R)
O = concatenate([R, I, J, K], axis=-1)
O = QuaternionConv2D(3, (5, 5), activation='relu', padding="same", kernel_initializer='quaternion')(O)
O = QuaternionBatchNormalization()(O)
O = AveragePooling2D(pool_size=(2, 2), strides=(2, 2), padding="same")(O)
O = QuaternionConv2D(7, (5, 5), activation='relu', padding="same", kernel_initializer='quaternion')(O)
O = QuaternionBatchNormalization()(O)
O = AveragePooling2D(pool_size=(2, 2), strides=(2, 2), padding="same")(O)
O = QuaternionConv2D(9, (5, 5), activation='relu', padding="same", kernel_initializer='quaternion')(O)
O = QuaternionBatchNormalization()(O)
F = AveragePooling2D(pool_size=(2, 2), strides=(2, 2), padding="same")(O)

O = Flatten()(F)
O = Dense(128)(O)
O = Dense(64)(O)
O = Dense(num_classes)(O)

model = Model(R, O)

# load the weights
model.load_weights('encryption/model.h5')

# get the metrix of meddle layer
model = Model(inputs=model.input, outputs=model.layers[13].output)
med_output = model.predict(x_test)

scio.savemat('tmp/test_meddle_layer.mat', {'F': med_output})
