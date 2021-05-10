# python3.8 arm-cross-compile
A script for cross compile standalone python for arm processor 


# Require docker & git

``` 
sudo apt-get install docker.io
sudo apt-get install git
```

# How to build and run docker? 

```
make
```

# How to build python3.8 from docker ? 

```
builder@87d06c922c5e:~$ ./build_arm-linux-gnueabihf.sh
```

At the end of the compilation, the python binaries are available here:

python-3.8.5/arm-linux-gnueabihf

```
.
├── build
│   ├── arm-linux-gnueabihf
├── build_arm-linux-gnueabihf.sh
├── build_x86_64-linux-gnu.sh
├── Dockerfile
├── Makefile
├── python-3.8.5
│   ├── arm-linux-gnueabihf
│   │   ├── bin
│   │   ├── include
│   │   ├── lib
│   │   └── share
└── README.md
```

