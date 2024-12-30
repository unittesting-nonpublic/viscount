# Viscount &mdash; A Direct Method Call Coverage for Java
[![codecov-python](https://codecov.io/github/unittesting-nonpublic/viscount/branch/main/graph/badge.svg?token=tkq655ROg3)](https://app.codecov.io/github/unittesting-nonpublic/viscount)
[![DOI 10.1109/ICSME58944.2024.00101](https://img.shields.io/badge/10.1109%2FICSME58944.2024.00101-black?logo=DOI)](https://doi.org/10.1109/ICSME58944.2024.00101)
![GitHub Licens[schematic.tex](images%2Fschematic.tex)e](https://img.shields.io/github/license/unittesting-nonpublic/viscount)

This repository contains the code for Viscount. Viscount analyzes direct method calls in Java program test code and their access modifiers using dynamic Java bytecode instrumentation (Javassist) and static analysis (Spoon) to examine production code method visibility.

Full Research Paper - [![DOI 10.1109/ICSME58944.2024.0003](https://img.shields.io/badge/10.1109%2FICSME58944.2024.00037-black?logo=DOI)](https://doi.org/10.1109/ICSME58944.2024.00037) 
(ICSME Research Track)

Tool Demo Paper - [![DOI 10.1109/ICSME58944.2024.00101](https://img.shields.io/badge/10.1109%2FICSME58944.2024.00101-black?logo=DOI)](https://doi.org/10.1109/ICSME58944.2024.00101)
(ICSME Tool Demo Track)

### Requirements
[viscount.sh](https://github.com/unittesting-nonpublic/viscount/blob/main/viscount.sh) setup:
- Java 8
- Python3
- `pip3 install -r requirements.txt`

Optional: Docker

Setting up the environment variables is required:
1. `MAVEN_HOME="PATH_TO_MVN"`
2. `JAVA_HOME="PATH_TO_JAVAJDK"`

### [Demo tutorial](https://www.youtube.com/watch?v=ZUyRtiUnbsU)

## Run
### Docker
Viscount can be called using Docker (container image - executable without root privilege) as follows:

```
docker build -t viscount-image .
```

```
docker run -v <path_to_project_folder>:/home/user/<project_folder> \
  -v <path_to_report_folder>:/home/user/<reportfolder> \
  viscount-image <project_name> /home/user/<projectfolder> /home/user/<reportfolder>
```

#### Requirements - [maven:3-open-jdk-8](https://hub.docker.com/layers/library/maven/3-openjdk-8/images/sha256-29cc4c106af036b3727fad911174511d5af3103710419e1fd3d0718aa217f7ae?context=explore) image

### Execution Without Docker

The main entry point of the tool is [viscount.sh](https://github.com/unittesting-nonpublic/viscount/blob/main/viscount.sh).

```
bash viscount.sh project-name /full/path/to/<project-name> /full/path/to/<resultfolder>
```
### Output

The output is two TSV files and a direct method call coverage (PDF) report in the `<path_to_report_folder>`

## Running example
By simply running viscount-example,

```
bash viscount.sh viscount-example /viscount/repo/directory/viscount-example /viscount/repo/directory/result
```

or you can simply clone [square-javapoet](https://github.com/square/javapoet/tree/f27ad04c9e7de4ec7b207979cfd47ec1d878ca03) and run
```
bash viscount.sh javapoet /viscount/repo/directory/javapoet /viscount/repo/directory/result
```
