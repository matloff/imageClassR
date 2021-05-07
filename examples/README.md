# TDAsweep Examples
## TDAsweep + Support Vector Machine
Here, we provide some example usage of TDAsweep with Support Vector Machine (SVM) in R. 

### How to run & general formatting
Each experiment is organized into independent functions (e.g., TDAsweep_demo_mnist()) that could be run directly without parameters.

If the user wishes to, they could also download the code and modify it according to their interest. The general code formatting is as following:

```
#------ Prepare & Format Dataset ------#

...

#------ Specify parameters for TDAsweep ------#

...

#------ Run TDAsweep for train and test set ------#

...

#------ Classification modeling ------#

...

#------ Evaluation ------#

...

```
More detailed commenting is also available in the code.


**Datasets used for demonstration include:**
- MNIST
  - Original source at: http://yann.lecun.com/exdb/mnist/
  - Kaggle download: https://www.kaggle.com/c/digit-recognizer
- Fashion-MNIST 
  - Original source at: https://github.com/zalandoresearch/fashion-mnist
  - Kaggle download: https://www.kaggle.com/zalando-research/fashionmnist
- CIFAR-10 
    - Original source at: https://www.cs.toronto.edu/~kriz/cifar.html
    - Kaggle download: https://www.kaggle.com/c/cifar-10
- Histology-MNIST (our example uses both the 28x28 and 64x64 non-RGB version dowloaded from kaggle)
    - Original source at:  https://zenodo.org/record/53169#.W6HwwP4zbOQ
    - Kaggle download: https://www.kaggle.com/kmader/colorectal-histology-mnist
- Kuzushiji-Mnist 
    - Original source at: https://github.com/rois-codh/kmnist
    - Kaggle download: https://www.kaggle.com/anokas/kuzushiji
- EMNIST 
    - Original source at: https://www.nist.gov/itl/products-and-services/emnist-dataset
    - Kaggle download: https://www.kaggle.com/crawford/emnist


