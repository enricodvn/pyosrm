cimport osrm
from enum import Enum

cdef class PyOSRM:
    cdef:
         osrm.EngineConfig engine_config
         osrm.OSRM* _thisptr

    def __cinit__(self, path, algorithm="CH", use_shared_memory=False):
        encoded_path = path.encode("UTF-8")
        cdef char* path_c = encoded_path
        cdef osrm.StorageConfig *store_config = new osrm.StorageConfig(path_c)
        self.engine_config.storage_config = store_config[0]
        self.engine_config.use_shared_memory = use_shared_memory

        if algorithm=="CH":
            self.engine_config.algorithm = osrm.Algorithm.CH
        elif algorithm=="MLD":
            self.engine_config.algorithm = osrm.Algorithm.MLD
        else:
            raise ValueError("algorithm can be either 'CH' or 'MLD'")

        self._thisptr = new osrm.OSRM(self.engine_config)


    def route(self, route_coords):
        cdef:
             osrm.FloatLongitude* lon
             osrm.FloatLatitude* lat
             osrm.Coordinate* coords
             osrm.RouteParameters *params = new osrm.RouteParameters()

        for coord in route_coords:
            lon = new osrm.FloatLongitude()
            lat = new osrm.FloatLatitude()
            lon[0].__value = <double>coord[0]
            lat[0].__value = <double>coord[1]
            coords = new osrm.Coordinate(lon[0], lat[0])
            params[0].coordinates.push_back(coords[0])

        result = Result()

        cdef osrm.Status status = self._thisptr[0].Route(params[0], result._thisptr[0])

        result.set_status(status)

        return result


    def __dealloc__(self):
        if self._thisptr != NULL:
            del self._thisptr

cdef class Result:
    cdef:
        osrm.ResultT* _thisptr
        osrm.Status _status

    property status:
        def __get__(self):
            return Status.Ok if self._status == osrm.Status.Ok else Status.Error

    def __cinit__(self):
        cdef osrm._JsonObject *jsonResult = new osrm._JsonObject()
        self._thisptr = new osrm.ResultT(jsonResult[0])

    cdef set_status(self, osrm.Status status):
        self._status = status

    def __dealloc__(self):
        if self._thisptr != NULL:
            del self._thisptr

class Status(Enum):
    Ok = 1
    Error = 2
