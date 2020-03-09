from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.unordered_map cimport unordered_map
from boost cimport path, optional

cdef extern from "storage/storage_config.hpp" namespace "osrm::storage":
    cdef cppclass IOConfig:
        IOConfig (vector[path] required_input_files_,
                  vector[path] optional_input_files_,
                  vector[path] output_files_) except +
        bool IsValid()
        path GetPath(string& fileName)
        path base_path

    cdef cppclass StorageConfig(IOConfig):
            StorageConfig(path& base)
            StorageConfig(char* base)

cdef extern from "engine_config.hpp" namespace "osrm":
    ctypedef enum Algorithm:
        CH "osrm::EngineConfig::Algorithm::CH"
        MLD "osrm::EngineConfig::Algorithm::MLD"

    struct EngineConfig:
        bool IsValid()
        StorageConfig storage_config
        int max_locations_trip
        int max_locations_viaroute
        int max_locations_distance_table
        int max_locations_map_matching
        double max_radius_map_matching
        int max_results_nearest
        int max_alternatives
        bool use_shared_memory
        path memory_file
        bool use_mmap
        Algorithm algorithm
        string verbosity
        string dataset_name

cdef extern from "status.hpp" namespace "osrm::engine":
    ctypedef enum Status:
        Ok "osrm::engine::Status::Ok"
        Error "osrm::engine::Status::Error"

cdef extern from "bearing.hpp" namespace "osrm":
    struct Bearing:
        short bearing
        short range
        bool IsValid()

cdef extern from "approach.hpp" namespace "osrm":
    cdef cppclass Approach:
        pass

cdef extern from "engine/hint.hpp" namespace "osrm::engine":
    struct Hint:
        pass

cdef extern from "util/coordinate.hpp" namespace "osrm::util":
    cdef cppclass FixedLongitude:
        pass
    cdef cppclass FixedLatitude:
        pass
    cdef cppclass FloatLongitude:
        # pass
        FloatLongitude()
        FloatLongitude(double)
        double __value
    cdef cppclass FloatLatitude:
        # pass
        FloatLatitude()
        FloatLatitude(double)
        double __value
    cdef cppclass Coordinate:
        FixedLongitude lon
        FixedLatitude lat
        Coordinate()
        Coordinate(FixedLongitude lon_, FixedLatitude lat_)
        Coordinate(FloatLongitude lon_, FloatLatitude lat_)
        bool IsValid()

cdef extern from "engine/api/base_parameters.hpp" namespace "osrm::engine::api":
    cdef cppclass SnappingType:
        pass
        # Default "osrm::engine::api::BaseParameters::SnappingType::Default"
        # Any "osrm::engine::api::BaseParameters::SnappingType::Any"

    cdef cppclass OutputFormatType:
        pass
        # JSON "osrm::engine::api::BaseParameters::OutputFormatType::JSON"
        # FLATBUFFERS "osrm::engine::api::BaseParameters::OutputFormatType::FLATBUFFERS"

    cdef cppclass BaseParameters:
        BaseParameters(vector[Coordinate] coordinates_, vector[optional[Hint]] hints_,
            vector[optional[double]] radiuses_, vector[optional[Bearing]] bearings_,
            vector[optional[Approach]] approaches_, bool generate_hints_,
            vector[string] exclude, SnappingType snapping_)
        vector[Coordinate] coordinates
        vector[optional[Hint]] hints
        vector[optional[double]] radiuses
        vector[optional[Bearing]] bearings
        vector[optional[Approach]] approaches
        vector[string] exclude
        optional[OutputFormatType] format
        bool generate_hints
        bool skip_waypoints
        SnappingType snapping

cdef extern from "route_parameters.hpp" namespace "osrm":
    cdef cppclass RouteParameters(BaseParameters):
        pass

cdef extern from "util/json_container.hpp" namespace "osrm::util::json":
    cdef cppclass Value:
        T get[T]()
    cdef cppclass _JsonObject "osrm::util::json::Object":
        unordered_map[string, Value] values
        _JsonObject()
    struct _Number "osrm::util::json::Number":
        double value
    struct _Array "osrm::util::json::Array":
        vector[Value] values
    struct _String "osrm::util::json::String":
        string value

cdef extern from "engine/api/base_result.hpp" namespace "osrm::engine::api":
    cdef cppclass ResultT:
        ResultT(_JsonObject value)
        T get[T]()

cdef extern from "osrm.hpp" namespace "osrm":
    cdef cppclass OSRM:
        OSRM() except +
        OSRM(EngineConfig &config) except +
        Status Route(RouteParameters &parameters, ResultT &result)
