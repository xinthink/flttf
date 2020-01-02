import tensorflow as tf
from tensorflow import keras
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image

mnist = keras.datasets.mnist
(x_train_orig, y_train), (x_test_orig, y_test) = mnist.load_data()
print("mnist dataset: train=%s test=%s" % (x_train_orig.shape, x_test_orig.shape))
# print("x_test_orig[0] =", x_test_orig[0])


class myCallback(keras.callbacks.Callback):
    def on_epoch_end(self, epoch, logs={}):
        self.model.stop_training = logs.get('accuracy') > 0.993


def rotate_images(arr, degree):
    img = Image.fromarray(arr)
    return np.array(img.rotate(degree))


x_train_rotated_left = [rotate_images(x, 20) for x in x_train_orig]
x_train_rotated_right = [rotate_images(x, 160) for x in x_train_orig]
x_test_rotated_left = [rotate_images(x, 20) for x in x_test_orig]
x_test_rotated_right = [rotate_images(x, 160) for x in x_test_orig]
x_train_orig = np.concatenate((x_train_orig, x_train_rotated_left, x_train_rotated_right), axis=0)
x_test_orig = np.concatenate((x_test_orig, x_test_rotated_left, x_test_rotated_right), axis=0)
y_train = np.concatenate((y_train, y_train, y_train), axis=0)
y_test = np.concatenate((y_test, y_test, y_test), axis=0)
print("dataset + roated images: train=%s test=%s y_train=%s y_test=%s" % (
    x_train_orig.shape, x_test_orig.shape, y_train.shape, y_test.shape))

x_train, x_test = x_train_orig / 255.0, x_test_orig / 255.0  # normalizing
model = keras.models.Sequential([
    keras.layers.Flatten(input_shape=(28, 28)),
    keras.layers.Dense(1024, activation='relu'),
    keras.layers.Dropout(0.2),
    keras.layers.Dense(1024, activation='relu'),
    keras.layers.Dropout(0.2),
    keras.layers.Dense(512, activation='relu'),
    keras.layers.Dropout(0.2),
    keras.layers.Dense(512, activation='relu'),
    keras.layers.Dropout(0.2),
    keras.layers.Dense(512, activation='relu'),
    keras.layers.Dropout(0.2),
    keras.layers.Dense(10, activation='softmax'),
])
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# model.fit(x_train,
#           y_train,
#           epochs=50)
model.fit(x_train,
          y_train,
          epochs=50,
          callbacks=[myCallback()])
model.evaluate(x_test, y_test)

tf.saved_model.save(model, 'models/mnist')
converter = tf.lite.TFLiteConverter.from_saved_model('models/mnist')
lite_model = converter.convert()
open('models/mnist/mnist.tflite', 'wb').write(lite_model)
