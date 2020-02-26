from setuptools import setup, Extension, find_packages
from Cython.Build import cythonize

ext = cythonize(
    [
        Extension(
            'pyosrm',
            sources=['**/*.pyx'],
            include_dirs=[
                '/usr/local/include/osrm',
                '/usr/include/boost'
            ],
            libraries=[
                "osrm",
                "boost_system",
                "boost_filesystem",
                "boost_iostreams",
                "boost_thread",
            ],
            library_dirs=["/usr/local/lib"],
            language='c++',
            extra_compile_args=["-std=c++14"],
            extra_link_args=["-lrt"]
        )
    ],
    compiler_directives={
        'language_level' : "3"
    },
)

setup(
    name='pyosrm',
    version='0.0.1',
    license='MIT',
    description='Cython wrapper of osrm-backend to be used in Python',
    author='Enrico Davini',
    url='https://github.com/enricodvn/pyosrm',
    packages=find_packages(where='src'),
    package_dir={'': 'src'},
    ext_modules=ext
)
