from setuptools import setup, Extension, find_packages
from Cython.Build import cythonize

# read the contents of your README file
from os import path
this_directory = path.abspath(path.dirname(__file__))
with open(path.join(this_directory, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

ext = cythonize(
    [
        Extension(
            'pyosrm',
            sources=['**/*.pyx'],
            include_dirs=[
                '/usr/local/include/osrm',
                '/usr/include/boost',
                '/usr/local/include/boost'
            ],
            libraries=[
                "osrm",
                "boost_system",
                "boost_filesystem",
                "boost_iostreams",
                "boost_thread",
            ],
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
    long_description=long_description,
    long_description_content_type='text/markdown',
    author='Enrico Davini',
    url='https://github.com/enricodvn/pyosrm',
    zip_safe=False,
    ext_modules=ext
)
