# pyosrm
Cython wrapper of osrm-backend to be used in Python.

##Dependencies

First things first, osrm-backend needs to be installed.

To install osrm-backend, follow the [instructions](https://github.com/Project-OSRM/osrm-backend#building-from-source) in the official repository.

##Installation
###Installing via pip

You can install using pip:

```
pip install pyosrm
```
###Installing from source
Clone the repository and make sure Cython is installed. Then proceed to install locally via pip:
```
pip install .
```
Or, if you want to build inline:
```
python setup.py build_ext --inplace
```
