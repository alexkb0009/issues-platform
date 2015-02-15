from setuptools import setup

setup(name='My Issues',
      version='0.1',
      description='Issues Web Application for BAC Project',
      author='Alexander Balashov',
      author_email='alex.balashov@gmail.com',
      url='http://www.python.org/sigs/distutils-sig/',
      install_requires=['wsgi-request-logger>=0.4', 'passlib>=1.6', 'Jinja2>=2.7', 'pymongo>=2.8']
#      install_requires=['Bottle>=0.13'],
     )
