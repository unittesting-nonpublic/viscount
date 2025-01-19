# Viscount &mdash; A Direct Method Call Coverage for Java Project
[![codecov-python](https://codecov.io/github/unittesting-nonpublic/viscount/branch/main/graph/badge.svg?token=tkq655ROg3)](https://app.codecov.io/github/unittesting-nonpublic/viscount)
[![DOI](https://zenodo.org/badge/DOI/10.1109/ICSME58944.2024.00101.svg)](https://doi.org/10.1109/ICSME58944.2024.00101)
![GitHub Licens[schematic.tex](images%2Fschematic.tex)e](https://img.shields.io/github/license/unittesting-nonpublic/viscount)

This repository contains the code for Viscount. It is a tool designed to analyze Java test suites by measuring the extent to which test cases directly invoke methods in the production code, categorized by their visibility levels --- public APIs or non-public methods (protected, package-private, private). This analysis helps identify tests that may be tightly coupled to implementation details, which is generally [discouraged](https://abseil.io/resources/swe-book/html/ch12.html#test_via_public_apis) in unit testing practices. It uses dynamic Java bytecode instrumentation ([Javassist](https://github.com/jboss-javassist/javassist)) to execute and analyze the test code, and static analysis ([Spoon](https://github.com/INRIA/spoon)) to examine production code method visibility.

Full Research Paper - [![DOI 10.1109/ICSME58944.2024.0003](https://img.shields.io/badge/10.1109%2FICSME58944.2024.00037-black?logo=DOI)](https://doi.org/10.1109/ICSME58944.2024.00037) 
(ICSME'24 Research Track)

Viscount Demo Paper - [![DOI 10.1109/ICSME58944.2024.00101](https://img.shields.io/badge/10.1109%2FICSME58944.2024.00101-black?logo=DOI)](https://doi.org/10.1109/ICSME58944.2024.00101)
(ICSME'24 Tool Demo Track)

### Requirements
- Java 8
- Maven 3
- Python3
- `pip3 install -r requirements.txt`
- Maven-build project

Optional: Docker


### [Demo tutorial](https://www.youtube.com/watch?v=ZUyRtiUnbsU)

## Run
### Docker
Viscount can be called using [Docker](https://www.docker.com/101-tutorial/) (container image - executable without root privilege, without the need to install any additional dependencies natively) as follows:

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

Setting up the environment variables is required:
1. `MAVEN_HOME="PATH_TO_MVN"`
2. `JAVA_HOME="PATH_TO_JAVAJDK"`

The main entry point of the tool is [viscount.sh](https://github.com/unittesting-nonpublic/viscount/blob/main/viscount.sh).

```
bash viscount.sh project-name /full/path/to/<project-name> /full/path/to/<reportfolder>
```
### Output

The output is two TSV files and a direct method call coverage (PDF) report in the `<reportfolder>`

## Running example
By simply running viscount-example,

```
bash viscount.sh viscount-example /viscount/repo/directory/viscount-example /viscount/repo/directory/result
```

or you can simply clone [square-javapoet](https://github.com/square/javapoet/tree/f27ad04c9e7de4ec7b207979cfd47ec1d878ca03) and run
```
bash viscount.sh javapoet /viscount/repo/directory/javapoet /viscount/repo/directory/result
```

## How to Contribute
To contribute to our work at [unittesting-nonpublic/viscount](https://github.com/unittesting-nonpublic/viscount), please follow these steps:

1. Fork and Clone: [Fork](https://help.github.com/articles/fork-a-repo/) the repository to your GitHub account, and [clone](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) it to your local machine.
2. Create a branch: In your forked repository, [create a new branch](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-and-deleting-branches-within-your-repository) with a descriptive name. Make your changes and ensure your commit messages clearly describe them.
3. Push and Resolve Conflicts: [Push your changes](https://docs.github.com/en/get-started/using-git/pushing-commits-to-a-remote-repository) to the new branch in your fork. Compare your branch with the main branch of this repository, and resolve any conflicts.
4. Submit a draft [pull request](https://docs.github.com/en/get-started/quickstart/hello-world#opening-a-pull-request) from your branch. In the description, [link]((https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/autolinked-references-and-urls) ) it to any related issues.

We appreciate any contributions!
