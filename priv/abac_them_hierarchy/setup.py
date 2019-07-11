# -*- coding: utf-8 -*-

# Learn more: https://github.com/kennethreitz/setup.py

from setuptools import setup, find_packages

setup(
    name='abac_them_hierarchy',
    version='0.0.1',
    description='Hierarchy for ABAC them implemented in Python',
    author='Geovane Fedrecheski',
    packages=find_packages(exclude=('tests', 'docs'))
)

print(find_packages())
