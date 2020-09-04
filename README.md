# mmWave V2X 3D ray-tracing

This is the 3D ray-tracing source code repository for [*M3 mmWave V2X testbed*](http://m3.ucsd.edu/mmwave-v2x-testbed/) project

## Getting Started

This code generates and runs a serise of Wireless Insite 3D tray-tracing simulations in a given scenario, with a SUMO generated traffic pattern.

### Prerequisites
 - A valid [Wireless Insite license](https://www.remcom.com/wireless-insite-em-propagation-software).
 - A "base" Wireless Insite simulation directory with fixed 3D models e.g. buildings, ground) and transmitters/receivers all properly configered.
 -  SUMO-generated traffic pattern. Save vehicle locations and types at each timestamp to one .mat file and put all files of one traffic pattern to one directory.
 - A set of vehicle models in the format of Wireless Insite 3D files (.object). The vehicle types should be consistent with the types in SUMO. Save the 3D models to one directory.

### Steps
 1. Runs "src/generate_sims.m" in matlab to generate simulation directories. Please carefully read the comments in the source file and make sure you meet all prerequisites.
 2. Runs "runWIbatch.py" with Python.
 3. Check "x3d/\*.sqlite" files in simulation directories for ray-tracing results. You can find the format of the sqlite file in the instruction that comes along with your Wireless Insite license.

## Citing the source code
``
@inproceedings{10.1145/3372224.3419208,
    author = {Wang, Song and Huang, Jingqi and Zhang, Xinyu},
    title = {{Demystifying Millimeter-Wave V2X: Towards Robust and Efficient Directional  Connectivity Under High Mobility}},
    year = {2020},
    doi = {10.1145/3372224.3419208},
    booktitle = {Proceedings of the 26th ACM Annual International Conference on Mobile Computing and Networking (MobiCom)},
}
``

## Contact
 - [Song Wang](https://s0ngwang.github.io), PhD student @ UC San Diego, email: sowang@ucsd.edu
 - [Jingqi Huang](https://jingqihuang.github.io), MS student @ UCSD (Now PhD student @ Purdue University), email:huan1504@purdue.edu
 - [Xinyu Zhang](http://xyzhang.ucsd.edu), Associate Professor @ UC San Diego, email: xyzhang@ucsd.edu