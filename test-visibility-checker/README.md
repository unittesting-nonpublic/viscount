# Test Method Visibility Checker

It is important to write tests that invoke the system being tested in the same way that the users would. 
Thus, making calls against its public API rather than the implementation details is the way that developers should write tests. 
Such tests could serve as a useful way for developers to understand what’s going on with the system under test.

In JUnit, you can write tests that call public, package-private, or protected methods (both package-private and protected need to be called in the right package and could not be called from just anywhere). 
Since it is important not to write tests against the implementation details, it is not recommended to write them on package-private or protected methods as it usually does not serve as a public API that could be accessed from anywhere.

[test-visibility-checker](https://github.com/firhard/test-visibility-checker) is a static analysis tool that can identify if a test method is calling non-public methods of the SUT.

## TODO:
- Include LambdaExpression Assertions 
- Analyse some of the lines that are missing from the checker
- More to add...

## Basic Understanding:
- [Java Access Modifiers](http://www.btechsmartclass.com/java/java-access-specifiers.html)

## Related Work:
- [Tests Code Visibility](https://link.springer.com/article/10.1007/s11219-016-9340-8)
- [EvoSuite (muTest)](https://dl.acm.org/doi/pdf/10.1145/1831708.1831728): (keyword: access modifiers) -> [AccessibleClassAdapter.java](https://github1s.com/evosuite/evosuite/blob/HEAD/client/src/main/java/org/evosuite/instrumentation/AccessibleClassAdapter.java#L31)
- [Private API Access on EvoSuite](https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=7927969)
- [Improving Oracle Quality by Detecting Brittle Assertions and Unused Inputs in Tests](https://dl.acm.org/doi/pdf/10.1145/2635868.2635917)

## Gray Literature:
- [Testing Methods & Access Modifiers: UIUC](https://courses.grainger.illinois.edu/cs126/sp2020/notes/testing-access-mods/)
- [Testing On the Toilet: Prefer Testing Public APIs Over Implementation-Detail Classes](https://docs.google.com/document/d/1ILEpaxZ9ntMEXNQuL-q4jWHF0QOAMo45elmomn29cZg/edit?pli=1)
- [While I don’t see any problems with testing private methods in general, they definitely have reduced utility in an API managed by design by contract.](https://therenegadecoder.com/code/maybe-its-not-okay-to-test-private-methods-at-least-when-using-design-by-contract/)
- [StackOverflow: Should I test Private Methods or only Public Ones](https://stackoverflow.com/questions/105007/should-i-test-private-methods-or-only-public-ones#comment19029_105209)
- [StackOverflow: Best answer is suggesting to use Reflection](https://stackoverflow.com/questions/34571/how-do-i-test-a-class-that-has-private-methods-fields-or-inner-classes?rq=1)
- [The Renegade Coder: It's okay to test private methods](https://therenegadecoder.com/code/its-okay-to-test-private-methods/)
- [Anthony Sciamanna: Should Private Methods be Tested](https://anthonysciamanna.com/2016/02/14/should-private-methods-be-tested.html)
- [Failures in private methods do not matter if you cannot break them from the public method](https://softwareengineering.stackexchange.com/questions/100959/how-do-you-unit-test-private-methods#comment272367_100959)
- [Artima: Testing Private Methods with JUnit and Suite Runner](https://www.artima.com/articles/testing-private-methods-with-junit-and-suiterunner)

## Developer Survey Question:
[Here](https://github.com/firhard/test-visibility-checker/blob/master/developer_survey.md)

## Example:
Clone [simple-java-maven-app](https://github.com/jenkins-docs/simple-java-maven-app) by [jenkins-docs](https://github.com/jenkins-docs) for a small example.
> IntelliJ:
   - Add [this command in your Run configuration](https://github.com/firhard/test-visibility-checker/blob/master/RunConfigurationsIntelliJ.png)
   - The output is two TSV files under the root of the __project__ folder:
     1. __project_name__\_all_method_visibility.tsv, and
        - a TSV file that contains all the methods (under __MavenLauncher.SOURCE_TYPE.APP_SOURCE__) and it's access modifiers 
     2. __project_name__\_method_visibility.tsv
        - a TSV file that contains all the methods being invoked by the tests (__MavenLauncher.SOURCE_TYPE.TEST_SOURCE__) in the project
   - Update __-DabsPath__ to change to another project
   - It is partially working on [commons-lang](https://github.com/apache/commons-lang). (Still under testing)
