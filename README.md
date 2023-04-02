# pyosrm
Cython wrapper of osrm-backend to be used in Python.

## Preliminaries: setup of libosrm on different systems

### On Mac OS X

On Mac OS X is as simple as using homebrew:

```
brew install osrm
```

Everything will go on its place (`/usr/local` or `/opt/homebrew` depending on the platform) and can be accessed by `pyosrm`.

### On Linux Ubuntu

On Ubuntu it's needed to build the library from source. To this aim the following required packages have to be installed:

```
sudo apt install build-essential git cmake pkg-config doxygen libboost-all-dev libtbb-dev lua5.2 liblua5.2-dev libluabind-dev libstxxl-dev libstxxl1v5 libxml2 libxml2-dev libosmpbf-dev libbz2-dev libzip-dev libprotobuf-dev
```

Then, the library source code can be downloaded from github:

```
git clone https://github.com/Project-OSRM/osrm-backend.git
```

and it can be built through the standard CMake workflow for creating the building system:

```
cd osrm-backend
mkdir build
cd build
cmake ..
```

To compile:

```
make
```

And finally to install it in the system (in the `/usr/local` subtree):

```
sudo make install
```

Indeed this will create the binaries for the different tools:

```
/usr/local/bin/osrm-extract
/usr/local/bin/osrm-partition
/usr/local/bin/osrm-customize
/usr/local/bin/osrm-contract
/usr/local/bin/osrm-datastore
/usr/local/bin/osrm-routed
```

And the static library:

```
/usr/local/lib/libosrm.a
```

## Installation
### Installing via pip

You can install using pip:

```
pip install pyosrm
```
This method is available only for Linux, since there is no wheel built for MacOS or Windows.



### Installing from source
First things first, osrm-backend needs to be installed.

To install osrm-backend, follow the instructions above.

Clone the repository. Then proceed to install locally via pip:
```
pip install .
```

## Usage
If you installed pyosrm using pip, you don't need to have osrm-backend installed, but it is most likely you will it first to pre-process the data, since this package does not provide the cli tools to do it yet. Follow the instructions in the [project wiki](https://github.com/Project-OSRM/osrm-backend/wiki/Running-OSRM#quickstart) to pre-process the data using the desired algorithm (CH or MLD).

To create a PyOSRM object, you need to pass the path to the pre-processed data, and the algorithm (default 'CH' or 'MLD').
```
import pyosrm
router = pyosrm.PyOSRM("tests/data/ch/monaco-latest.osrm")
```
For large datasets, it may be required [a lot of RAM](https://github.com/Project-OSRM/osrm-backend/wiki/Disk-and-Memory-Requirements) to run osrm. For this reason, if you have more than one python process instantiating a PyOSRM object, it is recommended to use shared memory instead.
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
### Nearest
To use the Nearest API, you need to pass a single coordinate in format [lon, lat]. 
```
from pyosrm import PyOSRM, Status
router = PyOSRM("tests/data/ch/monaco-latest.osrm", algorithm='CH')
result = router.nearest([7.4083429, 3.7378501])
if result.status == Status.Ok:
    print(result.json())
```

### Table
To use the Table API, you need to pass a list of coordinates in format [lon, lat]. Optionaly `source_indexes` and `destination_indexes` can be provided so to limit the sources to those indexes passed. `annotations` can be used to also report distances and not only `durations`.
```
from pyosrm import PyOSRM, Status
router = PyOSRM("tests/data/ch/monaco-latest.osrm", algorithm='CH')
result = router.table([(7.4083429, 3.7378501), (7.4176532280313318, 43.73133194618227), (7.418046070817755, 43.7257042928162)], source_indexes=[0, 1])
if result.status == Status.Ok:
    print(result.json())
```
