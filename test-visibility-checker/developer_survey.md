# Developer Survey
Have you ever experience any tests that fails in different version that does not reveal any new faults but rather it is because of a false positive assertions that is due to invoking method that consists of implementation details? 
Such tests are one of the characteristics of brittle test.

It could hamper the quality of a software system as it is not easy to differentiate between a false positive failing test(s) or there is a fault in the software.

In this survey, we would like to ask you for your software development practice when writing tests.

## Why participate?
* To learn about the possibility that writing tests could be standardized to only testing public API/method
* Learning about how other developers are dealing with this problem

## Questions: 
### (TODO: Fill Ethics form https://ethics.ris.shef.ac.uk/)

#### 1. Developers should separate (isolate) the implementation details from the public APIs.
   - Yes
   - No

#### 2. Developers should only write (unit) tests for Public API and this does not include non-public methods such as private, protected, and default (private-package). (Yes/No question)
   - Yes: If yes, is there any reason behind this? 
   - No: Have you come across maintenance issues (updating broken tests) more often if invoking non-public methods?

#### 3. How do you test private methods? [multiple choice]
   - Temporarily changing the method access modifier to public and not including it in the regression test suite
       1. Why do you think it is necessary to write tests for this type of method
   - Changing the access rights to private-package/protected permanently to create tests for it
   - Accessing private methods via the public APIs that invoke those methods.
       1. Playing Devil's Advocate:
           - Bad Defect Localization
           - Strong Coupling
           - Could also be Fragile
   - Use Java Reflection or Python Inspection to invoke private methods.
   - Not creating any test for private methods

#### 4. How often do you experience that testing only public methods will hinder the code coverage? (the need to write tests for non-public methods to achieve higher code coverage?)


#### 5. Which type of software architecture style that your team is using?
   - Representational state transfer (REST)
   - Microservices architecture
   - Component-based architecture
   - Client-service architecture (Cloud services)
   - Service-oriented architecture
   - Single-tiered architecture (No architecture)
   - Others

#### 6. Which type of testing practices do you use? [multiple choice]
   - Unit Testing
   - Integration Testing
   - Fuzzing (AFL, libFuzzer, Jazzer)
   - Property-Based Testing (Hypothesis)
   - Automated Test Generation (Randoop, Pynguin, EvoSuite)
   - Others

#### 7. What are some of the engineering goals that are required when creating a test in your project? [Multiple choice]
   - Meeting a certain number of test methods
   - Code Coverage
   - Mutation Score (Mutation Testing)
   - Exercising all methods at least once
   - Others

#### 8. Do you think it is hard for you to meet the engineering goal(s) if you only test public method?
   - Yes
   - No

#### 9. How many developers are working on your project?
   - 1
   - 2 - 10
   - 11- 50
   - 51 - 100
   - More than 100

#### 10. How many years of experience do you have in software development?
  - 1 - 2
  - 2 - 5
  - 5 - 10
  - More than 10