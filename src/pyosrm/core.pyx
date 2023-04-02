cimport osrm
from enum import Enum
import os
from collections.abc import Iterable



cdef class PyOSRM:
    cdef:
         osrm.OSRM* _thisptr

    def __cinit__(self, path="", algorithm="CH", use_shared_memory=False):
        cdef osrm.EngineConfig engine_config
        cdef char* path_c
        cdef osrm.StorageConfig *store_config
        if os.path.exists(path) or os.path.exists(path + '.fileIndex'):
            encoded_path = path.encode("UTF-8")
            path_c = encoded_path
            store_config = new osrm.StorageConfig(path_c)
            engine_config.storage_config = store_config[0]
        elif not use_shared_memory:
            raise ValueError(f"{path} is invalid: you need either a valid path or use_shared_memory True")
        engine_config.use_shared_memory = use_shared_memory
        if algorithm=="CH":
            engine_config.algorithm = osrm.Algorithm.CH
        elif algorithm=="MLD":
            engine_config.algorithm = osrm.Algorithm.MLD
        else:
            raise ValueError("algorithm can be either 'CH' or 'MLD'")

        self._thisptr = new osrm.OSRM(engine_config)

    def route(self, route_coords, generate_hints=True, steps=True, annotations=[]):
        cdef:
             osrm.FloatLongitude* lon
             osrm.FloatLatitude* lat
             osrm.Coordinate* coords
             osrm.RouteParameters *params = new osrm.RouteParameters()

        params[0].generate_hints = generate_hints
        params[0].steps = steps
        if annotations:
            params[0].annotations = True
            if not isinstance(annotations, str) and isinstance(annotations, Iterable):
                for annotation in annotations:
                    if annotation == "speed":
                        params[0].annotations_type = <osrm.RAnnotationsType>(<unsigned int>params[0].annotations_type | <unsigned int>osrm.RAnnotationsType.RSpeed)
                    elif annotation == "duration":
                        params[0].annotations_type = <osrm.RAnnotationsType>(<unsigned int>params[0].annotations_type | <unsigned int>osrm.RAnnotationsType.RDuration)
                    elif annotation == "nodes":
                        params[0].annotations_type = <osrm.RAnnotationsType>(<unsigned int>params[0].annotations_type | <unsigned int>osrm.RAnnotationsType.RNodes)
                    elif annotation == "distance":
                        params[0].annotations_type = <osrm.RAnnotationsType>(<unsigned int>params[0].annotations_type | <unsigned int>osrm.RAnnotationsType.RDistance)
                    elif annotation == "weight":
                        params[0].annotations_type = <osrm.RAnnotationsType>(<unsigned int>params[0].annotations_type | <unsigned int>osrm.RAnnotationsType.RWeight)
                    elif annotation == "datasources":
                        params[0].annotations_type = <osrm.RAnnotationsType>(<unsigned int>params[0].annotations_type | <unsigned int>osrm.RAnnotationsType.RDatasources)
                    elif annotation == "all":
                        params[0].annotations_type = <osrm.RAnnotationsType>(<unsigned int>params[0].annotations_type | <unsigned int>osrm.RAnnotationsType.RAll)
                    elif annotation == "none":
                        pass
                    else:
                        raise ValueError(f"Annotation {annotation} not recognized")
            else:
                if annotations == "all":
                    params[0].annotations_type = osrm.RAnnotationsType.RAll
                elif annotations == "none":
                    params[0].annotations_type = osrm.RAnnotationsType.RNoAnnotation
                else:
                    raise ValueError(f"Annotation {annotations} not recognized")

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
    
    def nearest(self, coord, number_of_results=1):
        cdef:
             osrm.FloatLongitude* lon
             osrm.FloatLatitude* lat
             osrm.Coordinate* coords
             osrm.NearestParameters *params = new osrm.NearestParameters()

        params[0].number_of_results = number_of_results        

        lon = new osrm.FloatLongitude()
        lat = new osrm.FloatLatitude()
        lon[0].__value = <double>coord[0]
        lat[0].__value = <double>coord[1]
        coords = new osrm.Coordinate(lon[0], lat[0])
        params[0].coordinates.push_back(coords[0])

        result = NearestResult()

        cdef osrm.Status status = self._thisptr[0].Nearest(params[0], result._thisptr[0])

        result.set_status(status)

        return result

    def table(self, route_coords, source_indexes=[], destination_indexes=[], annotations=[]):
        cdef:
             osrm.FloatLongitude* lon
             osrm.FloatLatitude* lat
             osrm.Coordinate* coords
             osrm.TableParameters *params = new osrm.TableParameters()

        for s in source_indexes:
            if s < 0 or s >= len(route_coords):
                raise ValueError(f'Source index {s} out of bounds')
            params[0].sources.push_back(s)

        for d in destination_indexes:
            if d < 0 or d >= len(route_coords):
                raise ValueError(f'Destination index {d} out of bounds')
            params[0].destinations.push_back(d)

        if annotations:
            if not isinstance(annotations, str) and isinstance(annotations, Iterable):
                for annotation in annotations:
                    if annotation == "duration":
                        params[0].annotations = <osrm.TAnnotationsType>(<unsigned int>params[0].annotations | <unsigned int>osrm.TAnnotationsType.TDuration)
                    elif annotation == "distance":
                        params[0].annotations = <osrm.TAnnotationsType>(<unsigned int>params[0].annotations | <unsigned int>osrm.TAnnotationsType.TDistance)
                    elif annotation == "all":
                        params[0].annotations = <osrm.TAnnotationsType>(<unsigned int>params[0].annotations | <unsigned int>osrm.TAnnotationsType.TAll)
                    elif annotation == "none":
                        pass
                    else:
                        raise ValueError(f"Annotation {annotation} not recognized")
            else:
                if annotations == "all":
                    params[0].annotations = osrm.TAnnotationsType.TAll
                elif annotations == "none":
                    params[0].annotations = osrm.TAnnotationsType.TNoAnnotation
                else:
                    raise ValueError(f"Annotation {annotations} not recognized")

        for coord in route_coords:
            lon = new osrm.FloatLongitude()
            lat = new osrm.FloatLatitude()
            lon[0].__value = <double>coord[0]
            lat[0].__value = <double>coord[1]
            coords = new osrm.Coordinate(lon[0], lat[0])
            params[0].coordinates.push_back(coords[0])

        result = TableResult()

        cdef osrm.Status status = self._thisptr[0].Table(params[0], result._thisptr[0])

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
            char* annotation_k = "annotation"
            char* speed_k = "speed"
            char* datasources_k = "datasources"
            char* nodes_k = "nodes"

        cdef osrm._JsonObject json_result = self._thisptr.get[osrm._JsonObject]()

        cdef:
            osrm._Array routes
            osrm._JsonObject route
            osrm._Array legs
            osrm._JsonObject leg
            osrm._Array waypoints
            osrm._JsonObject waypoint
            osrm._Array location
            osrm._JsonObject annotation
            osrm._Array annotations

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
                    _annotation = {}
                    if leg.values.find(annotation_k) != leg.values.end():
                        annotation = leg.values[annotation_k].get[osrm._JsonObject]()
                        if annotation.values.find(speed_k) != annotation.values.end():
                            annotations = annotation.values[speed_k].get[osrm._Array]()
                            _annotation['speed'] = [annotations.values.at(i).get[osrm._Number]().value for i in range(annotations.values.size())]
                        if annotation.values.find(duration_k) != annotation.values.end():                            
                            annotations = annotation.values[duration_k].get[osrm._Array]()
                            _annotation['duration'] = [annotations.values.at(i).get[osrm._Number]().value for i in range(annotations.values.size())]
                        if annotation.values.find(weight_k) != annotation.values.end():
                            annotations = annotation.values[weight_k].get[osrm._Array]()
                            _annotation['weight'] = [annotations.values.at(i).get[osrm._Number]().value for i in range(annotations.values.size())]
                        if annotation.values.find(datasources_k) != annotation.values.end():
                            annotations = annotation.values[datasources_k].get[osrm._Array]()
                            _annotation['datasources'] = [<unsigned int>annotations.values.at(i).get[osrm._Number]().value for i in range(annotations.values.size())]
                        if annotation.values.find(nodes_k) != annotation.values.end():
                            annotations = annotation.values[nodes_k].get[osrm._Array]()
                            _annotation['nodes'] = [<unsigned int>annotations.values.at(i).get[osrm._Number]().value for i in range(annotations.values.size())]
                        
                    parsed_legs.append({
                        "steps": [],
                        "distance": leg.values[distance_k].get[osrm._Number]().value,
                        "duration": leg.values[duration_k].get[osrm._Number]().value,
                        "summary": leg.values[summary_k].get[osrm._String]().value.decode("UTF-8"),
                        "annotation": _annotation
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

cdef class NearestResult:
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
            char* distance_k = "distance"
            char* waypoints_k = "waypoints"
            char* name_k = "name"
            char* hint_k = "hint"
            char* location_k = "location"
            char* message_k = "message"

        cdef osrm._JsonObject json_result = self._thisptr.get[osrm._JsonObject]()

        cdef:
            osrm._Array waypoints
            osrm._JsonObject waypoint
            osrm._Array location

        if self._status == osrm.Status.Error:
            return {
                "code": "Error",
                "message": json_result.values[message_k].get[osrm._String]().value
            }
        else:   
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
                "waypoints": parsed_waypoints,
                "code": "Ok" if self._status == osrm.Status.Ok else "Error"
            }

    cdef set_status(self, osrm.Status status):
        self._status = status

    def __dealloc__(self):
        if self._thisptr != NULL:
            del self._thisptr

cdef class TableResult:
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
            char* sources_k = "sources"
            char* destinations_k = "destinations"
            char* distance_k = "distance"
            char* duration_k = "duration"
            char* distances_k = "distances"
            char* durations_k = "durations"
            char* message_k = "message"
            char* name_k = "name"
            char* hint_k = "hint"
            char* location_k = "location"
            char* annotation_k = "annotation"

        cdef osrm._JsonObject json_result = self._thisptr.get[osrm._JsonObject]()

        cdef:
            osrm._Array sources
            osrm._Array destinations
            osrm._Array distances
            osrm._Array durations
            osrm._JsonObject waypoint
            osrm._Array location
            osrm._Array data

        if self._status == osrm.Status.Error:
            return {
                "code": "Error",
                "message": json_result.values[message_k].get[osrm._String]().value
            }
        else:
            sources = json_result.values[sources_k].get[osrm._Array]()
            parsed_sources = []

            for ii in range(sources.values.size()):
                waypoint = sources.values.at(ii).get[osrm._JsonObject]()
                location = waypoint.values[location_k].get[osrm._Array]()
                parsed_sources.append({
                    "distance": waypoint.values[distance_k].get[osrm._Number]().value,
                    "name": waypoint.values[name_k].get[osrm._String]().value.decode("UTF-8"),
                    "hint": waypoint.values[hint_k].get[osrm._String]().value.decode("UTF-8"),
                    "location": [location.values.at(0).get[osrm._Number]().value, location.values.at(1).get[osrm._Number]().value]
                })

            destinations = json_result.values[destinations_k].get[osrm._Array]()
            parsed_destinations = []

            for ii in range(sources.values.size()):
                waypoint = destinations.values.at(ii).get[osrm._JsonObject]()
                location = waypoint.values[location_k].get[osrm._Array]()
                parsed_destinations.append({
                    "distance": waypoint.values[distance_k].get[osrm._Number]().value,
                    "name": waypoint.values[name_k].get[osrm._String]().value.decode("UTF-8"),
                    "hint": waypoint.values[hint_k].get[osrm._String]().value.decode("UTF-8"),
                    "location": [location.values.at(0).get[osrm._Number]().value, location.values.at(1).get[osrm._Number]().value]
                })

            result = {
                "sources": parsed_sources,
                "destinations": parsed_destinations,
                "code": "Ok" if self._status == osrm.Status.Ok else "Error"
            }

            if  json_result.values.find(durations_k) != json_result.values.end():
                durations = json_result.values[durations_k].get[osrm._Array]()
                parsed_durations = []
                for ii in range(durations.values.size()):
                    parsed_durations.append([])
                    data = durations.values.at(ii).get[osrm._Array]()
                    for jj in range(data.values.size()):
                        parsed_durations[-1].append(data.values.at(jj).get[osrm._Number]().value)
                result['durations'] = parsed_durations

            if  json_result.values.find(distances_k) != json_result.values.end():
                distances = json_result.values[durations_k].get[osrm._Array]()
                parsed_distances = []
                for ii in range(distances.values.size()):
                    parsed_distances.append([])
                    data = distances.values.at(ii).get[osrm._Array]()
                    for jj in range(data.values.size()):
                        parsed_distances[-1].append(data.values.at(jj).get[osrm._Number]().value)
                result['distances'] = parsed_distances

            return result

    cdef set_status(self, osrm.Status status):
        self._status = status

    def __dealloc__(self):
        if self._thisptr != NULL:
            del self._thisptr

class Status(Enum):
    Ok = 1
    Error = 2
