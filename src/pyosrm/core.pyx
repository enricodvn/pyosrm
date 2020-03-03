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


    def route(self, route_coords, generate_hints=True):
        cdef:
             osrm.FloatLongitude* lon
             osrm.FloatLatitude* lat
             osrm.Coordinate* coords
             osrm.RouteParameters *params = new osrm.RouteParameters()

        params[0].generate_hints = generate_hints

        for coord in route_coords:
            lon = new osrm.FloatLongitude()
            lat = new osrm.FloatLatitude()
            lon[0].__value = <double>coord[0]
            lat[0].__value = <double>coord[1]
            coords = new osrm.Coordinate(lon[0], lat[0])
            params[0].coordinates.push_back(coords[0])

        result = RouteResult()

        cdef osrm.Status status = self._thisptr[0].Route(params[0], result._thisptr[0])

        result.set_status(status)

        return result


    def __dealloc__(self):
        if self._thisptr != NULL:
            del self._thisptr

cdef class RouteResult:
    cdef:
        osrm.ResultT* _thisptr
        osrm.Status _status

    property status:
        def __get__(self):
            return Status.Ok if self._status == osrm.Status.Ok else Status.Error

    def __cinit__(self):
        cdef osrm._JsonObject *jsonResult = new osrm._JsonObject()
        self._thisptr = new osrm.ResultT(jsonResult[0])

    def json(self):
        cdef:
            char* routes_k = "routes"
            char* distance_k = "distance"
            char* duration_k = "duration"
            char* message_k = "message"
            char* geometry_k = "geometry"
            char* weight_name_k = "weight_name"
            char* weight_k = "weight"
            char* legs_k = "legs"
            char* summary_k = "summary"
            char* waypoints_k = "waypoints"
            char* name_k = "name"
            char* hint_k = "hint"
            char* location_k = "location"

        cdef osrm._JsonObject json_result = self._thisptr.get[osrm._JsonObject]()

        cdef:
            osrm._Array routes
            osrm._JsonObject route
            osrm._Array legs
            osrm._JsonObject leg
            osrm._Array waypoints
            osrm._JsonObject waypoint
            osrm._Array location

        if self._status == osrm.Status.Error:
            return {
                "code": "Error",
                "message": json_result.values[message_k].get[osrm._String]().value
            }
        else:
            routes = json_result.values[routes_k].get[osrm._Array]()
            parsed_routes  = []

            for ii in range(routes.values.size()):
                route = routes.values.at(ii).get[osrm._JsonObject]()

                legs = route.values[legs_k].get[osrm._Array]()
                parsed_legs = []
                for jj in range(legs.values.size()):
                    leg = legs.values.at(jj).get[osrm._JsonObject]()
                    parsed_legs.append({
                        "steps": [],
                        "distance": leg.values[distance_k].get[osrm._Number]().value,
                        "duration": leg.values[duration_k].get[osrm._Number]().value,
                        "summary": leg.values[summary_k].get[osrm._String]().value.decode("UTF-8"),
                    })


                parsed_routes.append({
                    "distance": route.values[distance_k].get[osrm._Number]().value,
                    "duration": route.values[duration_k].get[osrm._Number]().value,
                    "legs": parsed_legs,
                    "geometry": route.values[geometry_k].get[osrm._String]().value.decode("UTF-8"),
                    "weight_name": route.values[weight_name_k].get[osrm._String]().value.decode("UTF-8"),
                    "weight": route.values[weight_k].get[osrm._Number]().value,
                })

            waypoints = json_result.values[waypoints_k].get[osrm._Array]()
            parsed_waypoints = []

            for ii in range(waypoints.values.size()):
                waypoint = waypoints.values.at(ii).get[osrm._JsonObject]()
                location = waypoint.values[location_k].get[osrm._Array]()
                parsed_waypoints.append({
                    "distance": waypoint.values[distance_k].get[osrm._Number]().value,
                    "name": waypoint.values[name_k].get[osrm._String]().value.decode("UTF-8"),
                    "hint": waypoint.values[hint_k].get[osrm._String]().value.decode("UTF-8"),
                    "location": [location.values.at(0).get[osrm._Number]().value, location.values.at(1).get[osrm._Number]().value]
                })

            return {
                "routes": parsed_routes,
                "waypoints": parsed_waypoints,
                "code": "Ok" if self._status == osrm.Status.Ok else "Error"
            }

    cdef set_status(self, osrm.Status status):
        self._status = status

    def __dealloc__(self):
        if self._thisptr != NULL:
            del self._thisptr

class Status(Enum):
    Ok = 1
    Error = 2
