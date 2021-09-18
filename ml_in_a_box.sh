# Install software for Ubuntu 20.04 ML-in-a-Box template VM on Paperspace Core
#
# Uses VM supplied by engineering
# After running, VM is templatized by them
# Script requires sudo access
# Installs go to standard locations, not ~/src as in previous 18.04 ML-in-a-Box template from 2018
# Script assumes a fresh copy of the VM, with the software to be installed not already present
# Some pip installs have alternative apt-get installs, but pip versions for Python/ML tend to be newer
#
# Last updated: Sep 18th 2021

### TODO ###

# Run from TensorFlow to end because failed with no space left on device
# Some of the installs are not specifying a software version, and may pick up the latest instead of a fixed one
# Rerun on fresh copy of the VM as sanity check, as the root user
# Engineering to QA the GPU/CUDA/NVidia setup
# GUI apps not tested: Chrome, JupyterLab, Atom
# CUDA toolkit install is not verified
# Check software licenses before distributing


#mkdir ~/src
#cd ~/src


# GPU
# ---

# - NVidia Driver 470.63.01 -

# VM is set up by engineering with latest driver as of Sep 15th 2021: 470.63.01

# - CUDA 11.4 -

# CUDA 11.4 is present on the VM as supplied by engineering

# - cuDNN 8.2.4.15-1+cuda11.4 -

# Following https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html section 2.3.4.1. Ubuntu Network Installation
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin

sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
sudo apt-get update

#sudo apt-get install libcudnn8=8.2.4.*-1+cuda11.4
#sudo apt-get install libcudnn8-dev=8.2.4.*-1+cuda11.4
sudo apt-get install libcudnn8=8.2.4.*-1+cuda11.4 -y
sudo apt-get install libcudnn8-dev=8.2.4.*-1+cuda11.4 -y

# CUDA toolkit (gives /usr/bin/nvcc)

#sudo apt install nvidia-cuda-toolkit
sudo apt-get install nvidia-cuda-toolkit -y

# Verify the install

### TODO: Install is not verified ###

# https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#verify says use /usr/src/cudnn_samples_v8/mnistCUDNN
# but the directory only contains NVIDIA_SLA_cuDNN_Support.txt, the license agreement
# It looks like the network install (2.3.4.1. Ubuntu Network Installation) doesn't have the code samples step corresponding to
# sudo dpkg -i libcudnn8-samples_8.x.x.x-1+cudax.x_{amd,arm}64.deb in the Debian install (2.3.2. Debian Installation)
# But that installation requires downloading cuDNN for Linux manually via the Nvidia website, not a script


# Infra
# -----

# - Docker Engine -

# https://docs.docker.com/engine/install/ubuntu/
# Docker engine, X86_64 architecture
# Use the repo method
# There is a convenience script, but it doesn't refer to a specific version

# Commands for repo
sudo apt-get update
#sudo apt-get install apt-transport-https ca-certificates gnupg lsb-release -y
sudo apt-get install apt-transport-https -y

# Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up repo (stable, not nightly/test)
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
#sudo apt-get install docker-ce docker-ce-cli containerd.io
sudo apt-get install docker-ce=5:20.10.8~3-0~ubuntu-focal docker-ce-cli=5:20.10.8~3-0~ubuntu-focal containerd.io -y

# Verify the install
sudo docker run hello-world


# - NVidia-Docker 2.6 -

# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html

# Stable repo and GPG key

distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Add experimental for A100 GPU features
#curl -s -L https://nvidia.github.io/nvidia-container-runtime/experimental/ubuntu20.04/nvidia-container-runtime.list | sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
curl -s -L https://nvidia.github.io/nvidia-container-runtime/experimental/$distribution/nvidia-container-runtime.list | sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list

# Install
sudo apt-get update
sudo apt-get install nvidia-docker2 -y
sudo systemctl restart docker

# Verify install
# Can see version with nvidia-docker version, which is better than nvidia-docker --version
sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi


# Python
# ------

# - Python 3.8.10 -

# This is now installed from one of the above steps: run with "python3", not "python"

# - pip3 20.0.2 -

# Works as "pip" or "pip3"
# pip can have newer versions of packages than Ubuntu's apt

sudo apt-get update
sudo apt-get install python3-pip -y

# - Numpy 1.21.2 -

#pip3 install numpy
pip3 install numpy==1.21.2

# - Pandas 1.3.3 -

#pip3 install pandas
pip3 install pandas==1.3.3

# - Matplotlib 3.4.3 -

#pip3 install matplotlib
pip3 install matplotlib==3.4.3

# - JupyterLab 3.1.12 -

# https://jupyterlab.readthedocs.io/en/stable/getting_started/installation.html
# Invoke with jupyter lab (not jupyterlab), appears on browser localhost:8888, or others

#pip3 install jupyterlab
pip3 install jupyterlab==3.1.12


# ML
# --

# - H2O-3 3.34.0.1 -

# https://docs.h2o.ai/h2o/latest-stable/h2o-docs/downloading.html

# Dependencies

# Says pip install requests, tabulate, future; requests is present
# Java is already installed from earlier in this script

#pip3 install tabulate
pip3 install tabulate==0.8.9
#pip3 install future
pip3 install future==0.18.2

# Install

#pip3 install -f http://h2o-release.s3.amazonaws.com/h2o/latest_stable_Py.html h2o
pip3 install -f https://h2o-release.s3.amazonaws.com/h2o/latest_stable_Py.html h2o==3.34.0.1

# Verify install

# This can be done interactively in Python, using
# python3 -c "import h2o; h2o.init(); h2o.demo('glm')"


# - Scikit-learn 0.24.2 -

# https://scikit-learn.org/stable/install.html
# This also installs SciPy 1.7.1

#pip3 install scikit-learn
pip3 install scikit-learn==0.24.2

# Verify install
python3 -c "import sklearn; sklearn.show_versions()"


# - TensorFlow 2.5.0 -

# https://www.tensorflow.org/install/pip

# GPU support is included by default; tensorflow-gpu is not required separately
# Note TF 2.5 not 2.6 yet

### TODO: Here to end, because no space left on device ###

pip3 install tensorflow==2.5.0

# Verify install

python3 -c "import tensorflow as tf;print(tf.reduce_sum(tf.random.normal([1000, 1000])))"
python3 -c "import tensorflow as tf; tf.config.list_physical_devices('GPU')" # GPUs (https://towardsdatascience.com/installing-tensorflow-gpu-in-ubuntu-20-04-4ee3ca4cb75d)


# - Nvidia RAPIDS 21.08 -

### TODO: Try with miniconda ###

# Requires conda (Anaconda/Miniconda) install or Docker container
# Source builds are for contributors
# Pip is not supported

# https://rapids.ai/start.html
# ...


# - PyTorch 1.9.0 -

# https://pytorch.org/get-started/locally/
# says pip3 install torch==1.9.0+cu111 torchvision==0.10.0+cu111 torchaudio==0.9.0 -f https://download.pytorch.org/whl/torch_stable.html
# but this is CUDA 11.1

# https://discuss.pytorch.org/t/pytorch-with-cuda-11-compatibility/89254/15
# says pip build is CUDA 11.1, nightlies 11.3, 11.4 needs source build until PyTorch 1.10

# https://github.com/pytorch/pytorch#from-source
# Source build instructions say use conda install with magma-cuda from https://anaconda.org/pytorch/repo

# https://anaconda.org/pytorch/repo
# But magma-cuda only goes to magma-cuda113, which is CUDA 11.3 


# Etc.
# ----

# - Atom 1.58 -

### TODO ###

# https://linuxize.com/post/how-to-install-atom-text-editor-on-ubuntu-20-04/
# sudo apt update
# sudo apt install software-properties-common apt-transport-https wget
# wget -q https://packagecloud.io/AtomEditor/atom/gpgkey -O- | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main"

# https://flight-manual.atom.io/getting-started/sections/installing-atom/#platform-linux

# Add package repo and GPG key
wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
sudo apt-get update

# Install
sudo apt-get install atom


# - Chrome 93.0 -

### TODO ###

# Leave this un-versioned to get latest, which is preferable for security
# Invoke with google-chrome

# https://linuxize.com/post/how-to-install-google-chrome-web-browser-on-ubuntu-20-04/
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb