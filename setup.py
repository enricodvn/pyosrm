from setuptools import setup, Extension, find_packages
from Cython.Build import cythonize
import platform
from ctypes.util import find_library
import os
import platform

# read the contents of your README file
from os import path
this_directory = path.abspath(path.dirname(__file__))
with open(path.join(this_directory, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

if platform.system() == 'Darwin':
    if platform.processor() == 'arm':
        include_dirs = [
            '/opt/homebrew/include/osrm',
            '/opt/homebrew/include/boost',
            '/usr/local/include/boost',
        ]
        library_dirs = [
            '/opt/homebrew/lib',
            '/usr/local/lib',
        ]       
    else:        
        include_dirs = [
            '/usr/local/include/osrm',
            '/usr/local/include/boost',
        ]
        library_dirs = [
            '/usr/local/lib',
            '/usr/lib',
        ]

    libraries = [
        "boost_system",
        "boost_filesystem",
        "boost_iostreams",
        "boost_thread",
        "osrm"
    ]
    os.environ['DYLD_FALLBACK_LIBRARY_PATH'] = ":".join(library_dirs)
    for i, library in enumerate(libraries):
        # Try dynamic libraries first
        if find_library(library):
            continue
        if library.startswith('boost') and not find_library(library) and find_library(library + '-mt'):
            # Try with the multithreading version
            library += '-mt'
            libraries[i] = library
            continue
        # fallback to static library
        found = False
        for dir in library_dirs:
            if os.path.isfile(os.path.join(dir, f'lib{library}.a')):
                found = True
                break
            if library.startswith('boost') and os.path.isfile(os.path.join(dir, f'lib{library}-mt.a')):
                library += '-mt'
                libraries[i] = library
                found = True
                break
        if found:
            continue
        raise SystemExit(f'Could not locate library {library}')    
    extra_link_args = []
elif platform.system() == 'Linux':
    include_dirs = [
        '/usr/local/include/osrm',
        '/usr/include/boost',
        '/usr/local/include/boost'
    ]
    library_dirs = [ '/usr/local/lib', '/usr/lib/x86_64-linux-gnu' ]
    libraries = [
        "osrm",
        "boost_system",
        "boost_filesystem",
        "boost_iostreams",
        "boost_thread",
        'rt',
        f'boost_python{"".join(platform.python_version().split(".")[:2])}'
    ]
    extra_link_args = ["-Wl,--no-undefined"]
    for i, library in enumerate(libraries):
        # Try dynamic libraries first
        found = False
        if find_library(library):            
            found = True
        else:
            for dir in library_dirs:
                if os.path.isfile(os.path.join(dir, f'lib{library}.a')):
                    found = True
                    break
                if library.startswith('boost') and os.path.isfile(os.path.join(dir, f'lib{library}-mt.a')):
                    library += '-mt'
                    libraries[i] = library
                    found = True
                    break
        if found:
            continue
        else:
            raise SystemExit(f'Could not locate library {library}')
else:
    raise SystemExit(f'Platform {platform.system()} is currently unsupported')

ext = cythonize(
    [
        Extension(
            'pyosrm',
            sources=['**/*.pyx'],
            include_dirs=include_dirs,
            library_dirs=library_dirs,
            libraries=libraries,
            language='c++',
            extra_compile_args=["-std=c++17"],
            extra_link_args=extra_link_args
        )
    ],
    compiler_directives={
        'language_level' : "3"
    },
)

setup(
    name='pyosrm',
    version='0.1.0',
    license='MIT',
    description='Cython wrapper of osrm-backend to be used in Python',
    long_description=long_description,
    long_description_content_type='text/markdown',
    author='Enrico Davini, Luca Di Gaspero',
    url='https://github.com/liuq/pyosrm',
    zip_safe=False,
    ext_modules=ext
)
