# Viscount

The main entry point of the tool is [viscount.sh](https://github.com/unittesting-nonpublic/viscount/blob/main/viscount.sh).

```
bash viscount.sh project-name /full/path/to/project-name /full/path/to/resultfolder
```

[viscount.sh](https://github.com/unittesting-nonpublic/viscount/blob/main/viscount.sh) setup:
- Java 8
- Python3

Setting up the environment variables is required:
1. `MAVEN_HOME="PATH_TO_MVN"`
2. `JAVA_HOME="PATH_TO_JAVAJDK"`


The output is two TSV files and a direct method call coverage report in the `/full/path/to/resultfolder`

### Running example
By simply running viscount-example,

```
bash viscount.sh viscount-example /viscount/repo/directory/viscount-example /viscount/repo/directory/result
```

or you can simply clone [square-javapoet](https://github.com/square/javapoet/tree/f27ad04c9e7de4ec7b207979cfd47ec1d878ca03) and run
```
bash viscount.sh javapoet /viscount/repo/directory/javapoet /viscount/repo/directory/result
```