# pyosrm
Cython wrapper of osrm-backend to be used in Python.

## Installation
### Installing via pip

You can install using pip:

```
pip install pyosrm
```
This method is available only for Linux, since there is no wheel built for MacOS or Windows.
### Installing from source
First things first, osrm-backend needs to be installed.

To install osrm-backend, follow the [instructions](https://github.com/Project-OSRM/osrm-backend#building-from-source) in the official repository. There is also a [wiki tutorial](https://github.com/Project-OSRM/osrm-backend/wiki/Building-OSRM) for other Linux distros. Don't use Mason, otherwise you will get some nasty segfault errors on your python code.

Clone the repository and make sure Cython is installed. Then proceed to install locally via pip:
```
pip install .
```
Or, if you want to build inline:
```
python setup.py build_ext --inplace
```
