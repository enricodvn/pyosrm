import pytest
import pyosrm

@pytest.fixture(autouse=True, params=["CH", "MLD"])
def initialized_router_instance(algorithm):
    router = pyosrm.PyOSRM('data/monaco-latest.osrm', algorithm=algorithm.param)
    yield router

@pytest.mark.parametrize('coords', [[7.419758, 43.731142], [7.419505, 43.736825]])
def test_valid_route(coords):
    result = router.route(coords)

    assert result.status == pyosrm.Status.Ok

    result_dict = result.json()

    assert "routes" in result_dict

    for route in result_dict["routes"]:
        assert "duration" in route
        assert "distance" in route
        assert "legs" in route
        assert "geometry" in route
        assert "weight_name" in route
        assert "weight" in route

        for leg in route["legs"]:
            assert "steps" in leg
            assert "duration" in leg
            assert "distance" in leg
            assert "summary" in leg

    assert "waypoints" in result_dict

    for waypoint in result_dict["waypoints"]:
        assert "hint" in waypoint
        assert "distance" in waypoint
        assert "location" in waypoint
        assert "name" in waypoint

    assert "code" in result_dict and result_dict["code"] == "Ok"
