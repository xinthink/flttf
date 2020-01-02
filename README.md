# flttf

A demonstration to use [TensorFlow Lite] in a [Flutter] project.

## Handwritten digits recognition

<img src='art/screenshot_digits_recognizer.jpg' width='480'>

### Train the model

A simple neural network is trained for the handwritting recognizer, using the [MNIST dataset], see `mnist.py` or `mnist.ipynb` for details.

Fits the model and save it to a `tflite` file:

```bash
# prepare the virtualenv
pipenv --python `which python3` install

# fits the model
pipenv run python mnist.py
```

You can also do further experiments using the Jupyter Notebook:

```pipenv run jupyter notebook mnist.ipynb```


## Real-time object detection

Use the pre-trained [Tiny YOLO v2] model.

### Convert the saved model file

Prepare a [virutalenv] with TensorFlow 1.x installed, using [Pipenv] for example:

```
pipenv --python `which python3` install tensorflow==1.15 opencv-python keras cython
```

install [darkflow](https://github.com/thtrieu/darkflow):

```
pipenv shell
git clone https://github.com/thtrieu/darkflow.git
cd darkflow
pip3 install -e .
```

download the [Tiny YOLO v2] model files:

```
curl https://pjreddie.com/media/files/yolov2-tiny.weights -o yolov2-tiny.weights
curl https://raw.githubusercontent.com/pjreddie/darknet/master/cfg/yolov2-tiny.cfg -o yolov2-tiny.cfg
curl https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names -o label.txt
```

convert weights to pb, and then tflite:

```bash
# convert to pb
flow --model yolov2-tiny.cfg --load yolov2-tiny.weights --savepb

# convert to tflite
tflite_convert \
  --graph_def_file=built_graph/yolov2-tiny.pb \
  --output_file=yolov2-tiny.tflite \
  --input_format=TENSORFLOW_GRAPHDEF \
  --output_format=TFLITE \
  --input_shape=1,416,416,3 \
  --input_array=input \
  --output_array=output \
  --inference_type=FLOAT \
  --input_data_type=FLOAT
```

the output will be a `yolov2-tiny.tflite` file under the current directory.


<!--
### Approach II

Use a [Keras implementation](https://github.com:qqwweee/keras-yolo3)

```
# download tiny yolo v3 model
curl https://pjreddie.com/media/files/yolov3-tiny.weights -o yolov3-tiny.weights
curl https://raw.githubusercontent.com/pjreddie/darknet/master/cfg/yolov3-tiny.cfg -o yolov3-tiny.cfg
curl https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names -o label.txt

# clone keras-yolo3
git clone git@github.com:qqwweee/keras-yolo3.git

# convert wights to h5
pip3 install keras
python3 keras-yolo3/convert.py yolov3-tiny.cfg yolov3-tiny.weights yolov3-tiny.h5
``` -->

[Flutter]: https://flutter.dev
[TensorFlow Lite]: https://www.tensorflow.org/lite
[MNIST dataset]: https://www.tensorflow.org/datasets/catalog/mnist
[Tiny YOLO v2]: https://pjreddie.com/darknet/yolov2/
[Pipenv]: https://pipenv.kennethreitz.org/
[Virtualenv]: https://virtualenv.pypa.io/
