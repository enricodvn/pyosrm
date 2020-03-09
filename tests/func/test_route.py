import pytest
import pyosrm

valid_coords = ([[7.419758, 43.731142], [7.419505, 43.736825]], )

@pytest.fixture(params=valid_coords, scope='class')
def valid_route_result(request, initialized_router_instance):
    return initialized_router_instance.route(request.param)

@pytest.fixture(scope='class')
def valid_result_dict(valid_route_result):
    return valid_route_result.json()

class TestValidRoute:

    def test_route(self, valid_route_result):
        assert valid_route_result.status == pyosrm.Status.Ok

    def test_routes_in_result_dict(self, valid_result_dict):
        assert "routes" in valid_result_dict
        assert isinstance(valid_result_dict["routes"], list)

    def test_duraton_in_route_dicts(self, valid_result_dict):
        for route in valid_result_dict["routes"]:
            assert "duration" in route
            assert isinstance(route["duration"], float)

    def test_distance_in_route_dicts(self, valid_result_dict):
        for route in valid_result_dict["routes"]:
            assert "distance" in route
            assert isinstance(route["distance"], float)

    def test_legs_in_route_dicts(self, valid_result_dict):
        for route in valid_result_dict["routes"]:
            assert "legs" in route
            for leg in route["legs"]:
                assert "steps" in leg and isinstance(leg["steps"], list)
                assert "duration" in leg and isinstance(leg["duration"], float)
                assert "distance" in leg and isinstance(leg["distance"], float)
                assert "summary" in leg and isinstance(leg["summary"], str)

    def test_geometry_in_route_dicts(self, valid_result_dict):
        for route in valid_result_dict["routes"]:
            assert "geometry" in route
            assert isinstance(route["geometry"], str)

    def test_weight_name_in_route_dicts(self, valid_result_dict):
        for route in valid_result_dict["routes"]:
            assert "weight_name" in route
            assert isinstance(route["weight_name"], str)

    def test_weight_in_route_dicts(self, valid_result_dict):
        for route in valid_result_dict["routes"]:
            assert "weight" in route
            assert isinstance(route["weight"], float)

    def test_waypoints_in_result_dict(self, valid_result_dict):
            assert "waypoints" in valid_result_dict
            assert isinstance(valid_result_dict["waypoints"], list)

    def test_hint_in_waypoint_dicts(self, valid_result_dict):
        for waypoint in valid_result_dict["waypoints"]:
            assert "hint" in waypoint
            assert isinstance(waypoint["hint"], str)

    def test_name_in_waypoint_dicts(self, valid_result_dict):
        for waypoint in valid_result_dict["waypoints"]:
            assert "name" in waypoint
            assert isinstance(waypoint["name"], str)

    def test_distance_in_waypoint_dicts(self, valid_result_dict):
        for waypoint in valid_result_dict["waypoints"]:
            assert "distance" in waypoint
            assert isinstance(waypoint["distance"], float)

    def test_location_in_waypoint_dicts(self, valid_result_dict):
        for waypoint in valid_result_dict["waypoints"]:
            assert "location" in waypoint
            assert isinstance(waypoint["location"], list)
            assert len(waypoint["location"]) == 2

    def test_code_in_result_dict(self, valid_result_dict):
        assert "code" in valid_result_dict and valid_result_dict["code"] == "Ok"

class TestRouteExceptions:

    def test_invalid_path_initialization(self):
        with pytest.raises(ValueError):
            pyosrm.PyOSRM("")

    def test_no_parameters_initialization(self):
        with pytest.raises(ValueError):
            pyosrm.PyOSRM()

    def test_invalid_algorithm_parameter(self):
        with pytest.raises(ValueError):
            pyosrm.PyOSRM("/", algorithm="dijkstra")
