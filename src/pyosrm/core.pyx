cimport osrm

cdef class PyOSRM:
    cdef:
         osrm.EngineConfig engine_config
         osrm.OSRM* _thisptr

    def __cinit__(self, char* path, algorithm="CH", use_shared_memory=False):
        cdef osrm.StorageConfig *store_config = new osrm.StorageConfig(path)
        self.engine_config.storage_config = store_config[0]
        self.engine_config.use_shared_memory = use_shared_memory

        if algorithm=="CH":
            self.engine_config.algorithm = osrm.Algorithm.CH
        elif algorithm=="MLD":
            self.engine_config.algorithm = osrm.Algorithm.MLD
        else:
            raise ValueError("Algorithm can be either 'CH' or 'MLD'")

        self._thisptr = new osrm.OSRM(self.engine_config)


    def route(coords):
        pass

    def __dealloc__(self):
        if self._thisptr != NULL:
            del self._thisptr
