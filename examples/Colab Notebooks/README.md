# TDAsweep versus Other Popular Dimension Reduction Techniques (histology-MNIST)

## Experiments include:
1. TDAsweep + AlexNet (Fully Connected Layers)
2. TDAsweep + Le-Net 5 (Fully Connected Layers)
3. AlexNet (Full)
4. Le-Net 5 (Full)
5. PCA + AlexNet (Fully Connected Layers)
6. PCA + Le-Net 5 (Fully Connected Layers)

Each experiment is run 20 times. Basic statistics (e.g., mean) and box-plots for these accuracies are available.

Simply run the cells and follow the notebook comments to execute the experiments and view results. More detailed commenting is also available in the code.

**Note: Pre-run datasets from TDAsweep for these experiments are in the *prerun_tdasweep* file. For the original datasets, please download them and put it in the same folder as the code.


**Datasets used for demonstration include:**
- Histology-MNIST (our example uses both the 28x28 and 64x64 non-RGB version dowloaded from kaggle)
    - Original source at:  https://zenodo.org/record/53169#.W6HwwP4zbOQ
    - Kaggle download: https://www.kaggle.com/kmader/colorectal-histology-mnist
- MedMNIST
    - Original source at: https://medmnist.github.io/


