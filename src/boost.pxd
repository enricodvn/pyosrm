from libcpp.vector cimport vector

cdef extern from "filesystem.hpp" namespace "boost::filesystem":
  cdef cppclass path:
    pass

cdef extern from "optional.hpp" namespace "boost::optional_ns":
  cdef cppclass optional[T]:
    pass
