# building for osx

## dependencies 
```sh
brew install boost git cmake libzip libstxxl libxml2 lua tbb ccache
```

## build and install the osrm
```sh
git clone https://github.com/Project-OSRM/osrm-backend.git
cd osrm-backend
./third_party/mason/mason install cmake 3.6.2
export PATH=$(./third_party/mason/mason prefix cmake 3.6.2)/bin:$PATH
mkdir build
cd build
cmake ../ -DENABLE_MASON=1
make install
```


## build the pyosrm now
```sh
pip install cython
pip install .
```