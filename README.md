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

To install osrm-backend, follow the [instructions](https://github.com/Project-OSRM/osrm-backend#building-from-source) in the official repository. There is also a [wiki tutorial](https://github.com/Project-OSRM/osrm-backend/wiki/Building-OSRM) for other platforms. Don't use Mason, otherwise you will get some nasty segfault errors on your python code.

Clone the repository and make sure Cython is installed. Then proceed to install locally via pip:
```
pip install .
```
Or, if you want to build inline:
```
python setup.py build_ext --inplace
```

## Usage
If you installed pyosrm using pip, you don't need to have osrm-backend installed, but it is most likely you will it first to pre-process the data, since this package does not provide the cli tools to do it yet. Follow the instructions in the [project wiki](https://github.com/Project-OSRM/osrm-backend/wiki/Running-OSRM#quickstart) to pre-process the data using the desired algorithm (CH or MLD).

To create a PyOSRM object, you need to pass the path to the pre-processed data, and the algorithm (default 'CH' or 'MLD').
```
import pyosrm
router = posrm.PyOSRM("tests/data/ch/monaco-latest.osrm")
```
For large datasets, it may be required [a lot of RAM](https://github.com/Project-OSRM/osrm-backend/wiki/Disk-and-Memory-Requirements) to run osrm. For this reason, if you have more than one python process instanciating a PyOSRM object, it is recommended to use shared memory instead.
```
import pyosrm
router = posrm.PyOSRM(use_shared_memory=True)
```
Refer to the [documentation](https://github.com/Project-OSRM/osrm-backend/wiki/Configuring-and-using-Shared-Memory) for more information about using shared memory with osrm.
### Route
To use the Route API, you just need to pass a list of coordinate pairs in format [lon, lat]. The easiest way to get the result is by using the RouteResult.json method, which formats the data in a easily serializable dictionary like the original API [result object](http://project-osrm.org/docs/v5.22.0/api/?language=cURL#result-objects).
```
from pyosrm import PyOSRM, Status
router = PyOSRM("tests/data/ch/monaco-latest.osrm", algorithm='CH')
result = router.route([[7.419758, 43.731142], [7.419505, 43.736825]])
if result.status == Status.Ok:
    print(result.json())
```
