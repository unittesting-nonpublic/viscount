package org.example;

import org.codehaus.plexus.util.xml.pull.XmlPullParserException;
import org.junit.*;
import org.mockito.Mockito;
import spoon.reflect.declaration.*;

import java.io.*;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

import spoon.support.reflect.declaration.CtParameterImpl;
import spoon.support.reflect.reference.CtTypeReferenceImpl;


public class TestVisibilityCheckerTest {

    @Ignore
    @Test
    public void testGetClasses_ReturnsValidClasses_AppSource() throws IOException, XmlPullParserException {
        String projectName = "viscount-example";
        String absPath = Paths.get("./src/test/resources/" + projectName + "/").toAbsolutePath().toString() + "/";
        String reportAbsPath = Paths.get("./src/test/resources/report/").toAbsolutePath().toString() + "/";
        TestVisibilityChecker checker = new TestVisibilityChecker(absPath, reportAbsPath);

        Set<String> classes = checker.getClasses(absPath, spoon.MavenLauncher.SOURCE_TYPE.APP_SOURCE);

        Assert.assertEquals(3, classes.size());
        String classname = "wallet.Wallet".replace(".", "/");
        Assert.assertTrue(classes.contains(classname));
        Assert.assertNotNull("Classes set should not be null.", classes);
        Assert.assertFalse("Classes set should not be empty.", classes.isEmpty());
    }

    @Test
    public void testGetClasses_HandlesInvalidPath() {
        String invalidPath = "./invalid/path/";
        String reportPath = "./src/test/resources/report/";
        TestVisibilityChecker checker = new TestVisibilityChecker(invalidPath, reportPath);

        try {
            checker.getClasses(invalidPath, spoon.MavenLauncher.SOURCE_TYPE.APP_SOURCE);
            Assert.fail("Expected exception not thrown for invalid path.");
        } catch (Exception e) {
            Assert.assertTrue("Exception should be thrown for invalid path.", true);
        }
    }

    @Ignore
    @Test
    public void testGetClassUnderTestAccessKind_ValidCUT() {
        String absPath = Paths.get("./src/test/resources/viscount-example/").toAbsolutePath() + "/";
        String reportAbsPath = Paths.get("./src/test/resources/report/").toAbsolutePath() + "/";
        TestVisibilityChecker checker = new TestVisibilityChecker(absPath, reportAbsPath);

        Map<String, ModifierKind> result = checker.getClassUnderTestAccessKind(absPath);

        Assert.assertTrue(result.containsKey("wallet.Wallet.capacity()"));
        Assert.assertEquals("protected",result.get("wallet.Wallet.capacity()").toString());
        Assert.assertEquals(9, result.size());
        Assert.assertNotNull("Result should not be null.", result);
        Assert.assertFalse("Result should not be empty.", result.isEmpty());
    }

    @Ignore
    @Test
    public void testRun_ValidPath() throws IOException, XmlPullParserException {
        String projectName = "viscount-example";
        Path filePath = Paths.get("./src/test/resources/" + projectName + "/");
        Path reportPath = Paths.get("./src/test/resources/report/");
        String absPath = filePath.toAbsolutePath().toString() + "/";
        String reportAbsPath = reportPath.toAbsolutePath().toString() + "/";

        TestVisibilityChecker checker = new TestVisibilityChecker(absPath, reportAbsPath);
        checker.run();

        File outputFile = new File(reportAbsPath + projectName + ".txt"); // Ensuring output file
        Assert.assertTrue("Output file should be created after run() execution.", outputFile.exists());

        File allMethodVisibility = new File(reportAbsPath + projectName + "_all_method_visibility.tsv"); // Ensuring output file
        Assert.assertTrue("Output file should be created after run() execution.", allMethodVisibility.exists());

        // Cleanup
        if (outputFile.exists()) {
            outputFile.delete();
        }

        if (allMethodVisibility.exists()) {
            allMethodVisibility.delete();
        }
    }

    @Test
    public void testRun_HandlesExceptions() {
        TestVisibilityChecker faultyChecker = new TestVisibilityChecker(null, null);
        try {
            faultyChecker.run();
            Assert.fail("run() should throw an exception if paths are not set correctly.");
        } catch (Exception e) {
            Assert.assertTrue("Exception should be thrown for invalid paths.", true);
        }
    }

    @Test
    public void testGetParametersAsString_ValidParameters() {
        List<CtParameter<?>> parameters = new ArrayList<>();

        CtParameter<?> parameter1 = new CtParameterImpl<>();
        parameter1.setType(new CtTypeReferenceImpl<>().setSimpleName("String"));
        parameters.add(parameter1);

        CtParameter<?> parameter2 = new CtParameterImpl<>();
        parameter2.setType(new CtTypeReferenceImpl<>().setSimpleName("int"));
        parameters.add(parameter2);

        String projectName = "viscount-example";
        String absPath = Paths.get("./src/test/resources/" + projectName + "/").toAbsolutePath() + "/";
        String reportAbsPath = Paths.get("./src/test/resources/report/").toAbsolutePath() + "/";

        TestVisibilityChecker checker = new TestVisibilityChecker(absPath, reportAbsPath);
        String result = checker.getParametersAsString(parameters);

        Assert.assertEquals("(String,int)", result);
    }

    @Ignore
    @Test
    public void testSpoonLauncher_ValidPathWithClasses() {
        String absPath = Paths.get("./src/test/resources/viscount-example/").toAbsolutePath() + "/";
        String reportAbsPath = Paths.get("./src/test/resources/report/").toAbsolutePath() + "/";
        TestVisibilityChecker checker = new TestVisibilityChecker(absPath, reportAbsPath);

        List<CtType<?>> result = checker.spoonLauncher(absPath, spoon.MavenLauncher.SOURCE_TYPE.APP_SOURCE);
        Assert.assertNotNull("Result should not be null.", result);
        Assert.assertFalse("Result should not be empty.", result.isEmpty());
    }

    @Test(expected = RuntimeException.class)
    public void testSpoonLauncher_ValidPathWithoutClasses() {
        String emptyProjectName = "empty-project";
        String absPath = Paths.get("./src/test/resources/" + emptyProjectName + "/").toAbsolutePath() + "/";
        String reportAbsPath = Paths.get("./src/test/resources/report/").toAbsolutePath() + "/";
        TestVisibilityChecker checker = new TestVisibilityChecker(absPath, reportAbsPath);

        List<CtType<?>> result = checker.spoonLauncher(absPath, spoon.MavenLauncher.SOURCE_TYPE.APP_SOURCE);
        Assert.assertNotNull("Result should not be null.", result);
        Assert.assertTrue("Result should be empty for a project with no classes.", result.isEmpty());
    }

    @Test(expected = RuntimeException.class)
    public void testSpoonLauncher_InvalidPath() {
        String invalidPath = "./invalid/path/";
        String reportPath = "./src/test/resources/report/";
        TestVisibilityChecker checker = new TestVisibilityChecker(invalidPath, reportPath);

        checker.spoonLauncher(invalidPath, spoon.MavenLauncher.SOURCE_TYPE.APP_SOURCE);
    }

    @Test
    public void testGetParametersAsString_EmptyParameters() {
        List<CtParameter<?>> parameters = new ArrayList<>();
        String projectName = "viscount-example";
        String absPath = Paths.get("./src/test/resources/" + projectName + "/").toAbsolutePath() + "/";
        String reportAbsPath = Paths.get("./src/test/resources/report/").toAbsolutePath() + "/";
        TestVisibilityChecker checker = new TestVisibilityChecker(absPath, reportAbsPath);
        String result = checker.getParametersAsString(parameters);

        Assert.assertEquals("()", result);
    }

    @Test
    public void testGetMethodParameters_ValidParameters() {
        CtParameter<?> parameter1 = new CtParameterImpl<>();
        parameter1.setType(new CtTypeReferenceImpl<>().setSimpleName("String"));

        CtParameter<?> parameter2 = new CtParameterImpl<>();
        parameter2.setType(new CtTypeReferenceImpl<>().setSimpleName("int"));

        List<CtParameter<?>> parameters = Arrays.asList(parameter1, parameter2);

        CtMethod<?> mockMethod = Mockito.mock(CtMethod.class);
        Mockito.when(mockMethod.getParameters()).thenReturn(parameters);

        String projectName = "viscount-example";
        String absPath = Paths.get("./src/test/resources/" + projectName + "/").toAbsolutePath() + "/";
        String reportAbsPath = Paths.get("./src/test/resources/report/").toAbsolutePath() + "/";
        TestVisibilityChecker checker = new TestVisibilityChecker(absPath, reportAbsPath);
        String result = checker.getMethodParameters(mockMethod);

        Assert.assertEquals("(String,int)", result);
    }

    @Test
    public void testGetMethodParameters_EmptyParameters() {
        List<CtParameter<?>> parameters = new ArrayList<>();

        CtMethod<?> mockMethod = Mockito.mock(CtMethod.class);
        Mockito.when(mockMethod.getParameters()).thenReturn(parameters);

        String projectName = "viscount-example";
        String absPath = Paths.get("./src/test/resources/" + projectName + "/").toAbsolutePath() + "/";
        String reportAbsPath = Paths.get("./src/test/resources/report/").toAbsolutePath() + "/";
        TestVisibilityChecker checker = new TestVisibilityChecker(absPath, reportAbsPath);
        String result = checker.getMethodParameters(mockMethod);

        Assert.assertEquals("()", result);
    }
}