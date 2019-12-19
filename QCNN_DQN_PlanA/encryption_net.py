import keras
from keras.models import Model
from keras.models import Sequential
from keras.layers import Dense, AveragePooling2D, Flatten, Input, Activation, Convolution2D, concatenate
from quaternion_layers.conv import QuaternionConv2D
from keras.preprocessing.image import ImageDataGenerator
import scipy.io as scio
import numpy as np


batch_size = 128
num_classes = 36
epochs = 1000

def learnVectorBlock(I):
    """Learn initial vector component for input."""
    O = Convolution2D(1, (5, 5), padding='same', activation='relu')(I)
    return O

# input image dimensions
img_rows, img_cols = 64, 64
input_shape = (img_rows, img_cols, 1)

x_data = scio.loadmat('tmp/input.mat')
x_data = x_data['X']
y_data = scio.loadmat('tmp/label.mat')
y_data = y_data['T']

# normalize the y_data in the range of 36 classes
y_min = y_data.min(axis=1)
y_max = y_data.max(axis=1)
y_min2 = y_max
for i in range(36):
    if y_data[0][i] < y_min2 and y_data[0][i] != y_min:
        y_min2 = y_data[0][i]
for i in range(36):
    if y_data[0][i] == y_min:
        y_data[0][i] = 0
    elif y_data[0][i] == y_max:
        y_data[0][i] = 35
    else:
        y_data[0][i] = 35 * (y_data[0][i] - y_min2) // (y_max - y_min2)

x_data = x_data.astype('float32')
y_data = y_data.astype('float32')

# reshape x_train and y_train
x_data = np.swapaxes(x_data, 0, -1)
x_train = np.expand_dims(x_data, axis=-1)
y_train = np.swapaxes(y_data, 0, -1)

datagen = ImageDataGenerator(
    featurewise_center=True,
    featurewise_std_normalization=True)

datagen.fit(x_train)

# convert class vectors to binary class matrices
y_train = keras.utils.to_categorical(y_train, num_classes)

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
model.compile(loss=keras.losses.categorical_crossentropy,
              optimizer=keras.optimizers.Adam(),
              metrics=['accuracy'])

model.fit_generator(datagen.flow(x_train, y_train, batch_size=batch_size),
                    steps_per_epoch=len(x_train) / batch_size, epochs=epochs)

# save the net and weights
model.save_weights('encryption/model.h5')

# get the metrix of meddle layer
med_model = Model(inputs=model.input, outputs=model.layers[8].output)
med_output = med_model.predict(x_train)

scio.savemat('tmp/meddle_layer.mat', {'F':med_output})
