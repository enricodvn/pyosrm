import sys
from setuptools import setup, Extension, find_packages
from Cython.Build import cythonize

# read the contents of your README file
from os import path
this_directory = path.abspath(path.dirname(__file__))
with open(path.join(this_directory, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()


if sys.platform == "darwin":
    libs = [
            "osrm",
            "boost_system",
            "boost_filesystem",
            "boost_iostreams",
            "boost_thread-mt",
        ]
    extra_link_args = []

else :
    libs = [
            "osrm",
            "boost_system",
            "boost_filesystem",
            "boost_iostreams",
            "boost_thread",
        ]
    extra_link_args = ["-lrt"]
ext = cythonize(
    [
        Extension(
            'pyosrm',
            sources=['**/*.pyx'],
            include_dirs=[
                '/usr/local/include/osrm',
                '/usr/local/include/',
                '/usr/include/boost',
                '/usr/local/include/boost'
            ],
            libraries=libs,
            language='c++',
            extra_compile_args=["-std=c++14"],
            extra_link_args=extra_link_args
        )
    ],
    compiler_directives={
        'language_level' : "3"
    },
)

setup(
    name='pyosrm',
    version='0.0.2',
    license='MIT',
    description='Cython wrapper of osrm-backend to be used in Python',
    long_description=long_description,
    long_description_content_type='text/markdown',
    author='Enrico Davini',
    url='https://github.com/enricodvn/pyosrm',
    zip_safe=False,
    ext_modules=ext
)
