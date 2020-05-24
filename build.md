# Building for osx

## Preparing dependencies 
You will need homebrew to be installed on your machine before doing this.

```sh
# install dependencies for building the routing engine
brew install boost git cmake libzip libstxxl libxml2 lua tbb ccache
```

## Build and install the osrm

**Attention: Do not use the MESON because the build will be linked with other libs than the pyosrm will use to link the python libs and this will cause missing symbols to be reported.**

```sh
# clone osrm routing engine
git clone https://github.com/Project-OSRM/osrm-backend.git

# prepare for build
cd osrm-backend
mkdir build && cd build
cmake ../

# build and install
make install
```


## Build the **pyosrm**
```sh
# needed for linking python with cpp libs
pip install cython

# do the install of the lib locally (venv or not)
pip install .
```

## Preparing map file
You should pay attention to the ```ALGO``` that you want to use for **osrm**. With default algo (**CH**) for **pyosrm** you can follow the example bellow to generate your osrm file.
```sh
# download file
wget http://download.geofabrik.de/europe/germany/berlin-latest.osm.pbf

# extract routing info
osrm-extract berlin-latest.osm.pbf -p profiles/car.lua

# contract edges and build final file
osrm-contract berlin-latest.osrm
```

If ```profiles/car.lua``` si not found you can use full location of the install path ```/usr/local/share/osrm/profiles/car.lua```