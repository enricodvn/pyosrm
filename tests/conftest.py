import pytest
import pyosrm

@pytest.fixture(params=[{"algorithm": 'CH', "path": "tests/data/ch/monaco-latest.osrm"},
                        {"algorithm": 'MLD', "path": "tests/data/mld/monaco-latest.osrm"}])
def initialized_router_instance(request):
    router = pyosrm.PyOSRM(request.param["path"], algorithm=request.param["algorithm"])
    return router
