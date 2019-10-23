import tensorflow as tf
from tensorflow import keras

mnist = keras.datasets.mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()
print("mnist dataset, train=%s, test=%s" % (x_train.shape, x_test.shape))

x_train, x_test = x_train / 255.0, x_test / 255.0  # normalizing
model = keras.models.Sequential([
    keras.layers.Flatten(input_shape=(28, 28)),
    keras.layers.Dense(128, activation='relu'),
    keras.layers.Dropout(0.2),
    keras.layers.Dense(10, activation='softmax'),
])
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])


class myCallback(keras.callbacks.Callback):
    def on_epoch_end(self, epoch, logs={}):
        self.model.stop_training = logs.get('accuracy') > 0.99


model.fit(x_train,
          y_train,
          epochs=50,
          callbacks=[myCallback()])
model.evaluate(x_test, y_test)
tf.saved_model.save(model, 'models/digits_mnist')
converter = tf.lite.TFLiteConverter.from_saved_model('models/digits_mnist')
lite_model = converter.convert()
open('models/digits_mnist.tflite', 'wb').write(lite_model)
