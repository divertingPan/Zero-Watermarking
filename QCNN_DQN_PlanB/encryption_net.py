import keras
from keras.models import Model
from keras.layers import Dense, AveragePooling2D, Flatten, Input, Convolution2D, concatenate, Activation, BatchNormalization
from quaternion_layers.conv import QuaternionConv2D
from quaternion_layers.bn import QuaternionBatchNormalization
from keras.preprocessing.image import ImageDataGenerator
import scipy.io as scio
import numpy as np


batch_size = 128
num_classes = 36
epochs = 1000


def learnVectorBlock(I):
    """Learn initial vector component for input."""
    O = Convolution2D(3, (5, 5), padding='same', activation='relu')(I)
    return O


# input image dimensions
img_rows, img_cols = 56, 56
input_shape = (img_rows, img_cols, 3)

x_data = scio.loadmat('tmp/input.mat')
x_data = x_data['sub_img']
y_data = scio.loadmat('tmp/label.mat')
y_data = y_data['T']

x_train = x_data.astype('float32')
y_train = y_data.astype('float32')


datagen = ImageDataGenerator(
    featurewise_center=True,
    featurewise_std_normalization=True)

datagen.fit(x_train)


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
model.compile(loss=keras.losses.mse,
              optimizer=keras.optimizers.Adam(lr=0.001, decay=0.9),
              metrics=['accuracy'])

model.fit_generator(datagen.flow(x_train, y_train, batch_size=batch_size),
                    steps_per_epoch=len(x_train) / batch_size, epochs=epochs)

# save the net and weights
model.save_weights('encryption/model.h5')

# get the metrix of meddle layer
med_model = Model(inputs=model.input, outputs=model.layers[13].output)
# med_model = Model(inputs=model.input, outputs=model.layers[17].output)
med_output = med_model.predict(x_train)


scio.savemat('tmp/meddle_layer.mat', {'F': med_output})
