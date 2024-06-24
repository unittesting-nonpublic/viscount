package org.example;

import com.opencsv.CSVWriter;
import org.apache.maven.shared.invoker.MavenInvocationException;
import org.codehaus.plexus.util.xml.pull.XmlPullParserException;
import spoon.MavenLauncher;
import spoon.reflect.CtModel;
import spoon.reflect.declaration.*;
import spoon.reflect.visitor.filter.TypeFilter;

import java.io.*;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

public class TestVisibilityChecker {
    private final String absPath;
    private static String reportPath;

    private TestVisibilityChecker(String absPath) {
        this.absPath = absPath;
    }

    public void run() throws XmlPullParserException, IOException {
        getClassUnderTestAccessKind2(absPath);
        Map<String,ModifierKind> CUTAccessKind = getClassUnderTestAccessKind(absPath);
        writeCUTToCsv(CUTAccessKind);
    }

    private Map<String,ModifierKind> getClassUnderTestAccessKind(String absPath) {
        List<CtType<?>> CUTClasses = spoonLauncher(absPath, MavenLauncher.SOURCE_TYPE.APP_SOURCE);
        return getCUTClasses(CUTClasses);
    }

    private Set<String> getClasses(String path, MavenLauncher.SOURCE_TYPE testSource) throws XmlPullParserException, IOException {
        MavenLauncher CUTLauncher = new MavenLauncher(path,testSource);
        CUTLauncher.getEnvironment().setSourceClasspath(getPathToJunit(path, testSource));
        CtModel CUTModel = CUTLauncher.buildModel();

        List<String> list = new ArrayList<>();
        CUTModel.getElements(new TypeFilter<>(CtClass.class)).forEach(ctClass -> {
            list.add(ctClass.getQualifiedName().replace(".","/"));
        });
        Set<String> testSet = new HashSet<>(list);
        return testSet;
    }

    private void getClassUnderTestAccessKind2(String absPath) throws IOException, XmlPullParserException {
        Set<String> CUTClasses = getClasses(absPath, MavenLauncher.SOURCE_TYPE.APP_SOURCE);
        Set<String> TestClasses = getClasses(absPath, MavenLauncher.SOURCE_TYPE.TEST_SOURCE);

        StringBuilder resultBuilder = new StringBuilder();

        for (String element : CUTClasses) {
            if (resultBuilder.length() > 0) resultBuilder.append(",");
            resultBuilder.append(element);
        }

        resultBuilder.append("_whynotutopia_");

        StringBuilder resultBuilder2 = new StringBuilder();

        for (String element : TestClasses) {
            if (resultBuilder2.length() > 0) resultBuilder2.append(",");
            resultBuilder2.append(element);
        }

        resultBuilder.append(resultBuilder2);

        FileWriter fileWriter = new FileWriter(reportPath
                + absPath.split("/")[absPath.split("/").length - 1]
                + ".txt");
        fileWriter.write(resultBuilder.toString());
        fileWriter.close();
    }

    private List<CtType<?>> spoonLauncher(String path, MavenLauncher.SOURCE_TYPE testSource){
        MavenLauncher CUTLauncher = new MavenLauncher(path,testSource);
        CUTLauncher.getEnvironment().setSourceClasspath(getPathToJunit(path, testSource));
        CtModel CUTModel = CUTLauncher.buildModel();

        ArrayList<CtType<?>> al = new ArrayList();
        CUTModel.getElements(new TypeFilter<>(CtClass.class)).forEach(ctClass -> al.add(ctClass));
        CUTModel.getElements(new TypeFilter<>(CtInterface.class)).forEach(ctInterface -> al.add(ctInterface));
        return al;
    }

    private Map<String,ModifierKind> getCUTClasses(List<CtType<?>> CUTClasses){
        Map<String,ModifierKind> CUTAccessKind = new HashMap<>();
        CUTClasses.forEach(CUTClass -> {
            CUTClass.getMethods().forEach(method -> {
                if (method.getBody() != null) {
                    CUTAccessKind.put(fullMethodName(method), method.getVisibility());
                }
            });
        });

        Iterator<Map.Entry<String, ModifierKind>> iterator = CUTAccessKind.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<String, ModifierKind> entry = iterator.next();
            if (!entry.getKey().contains(".")) iterator.remove();
            else if (entry.getKey().startsWith("java.") || entry.getKey().startsWith("org.example.ModifyCUT") ||
                    entry.getKey().startsWith("org.example.TestVisibilityChecker") ||
                    entry.getKey().startsWith("org.example.InvokeMaven"))
                iterator.remove();
        }

        return CUTAccessKind;
    }

    private void writeCUTToCsv(Map<String, ModifierKind> testAccessKind) {
        if(testAccessKind.size() == 0) {
            System.out.println("Project setup failed: " + absPath.split("/")[absPath.split("/").length - 1]);

            try (CSVWriter writer = new CSVWriter(new FileWriter(reportPath + "zzz_fail_project.csv", true))) {
                writer.writeNext(new String[]{String.valueOf(absPath.split("/")[absPath.split("/").length - 1]),
                        String.valueOf(Instant.now()),"No TestAccessKind"});
            } catch (IOException e) {
                e.printStackTrace();
            }

            System.exit(0);
        }

        try (PrintWriter writer = new PrintWriter(new FileWriter(reportPath
                + absPath.split("/")[absPath.split("/").length - 1]
                + "_all_method_visibility.tsv"))) {
            writer.println(String.join("\t", new String[]{"method", "visibility"}));
            testAccessKind.forEach((key, value) -> {
                writer.println(key.replaceAll("\\r\\n|\\r|\\n", " ") + "\t" + ((value == null) ? "package-private" : value));
            });
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private String fullMethodName(CtMethod<?> method) {
        if (method.getDeclaringType().getPackage() != null) {
            return method.getDeclaringType().getPackage().getQualifiedName() + "."
                    + method.getDeclaringType().getSimpleName() + "."
                    + method.getSimpleName() + getMethodParameters(method);
        }
        return method.getSimpleName();
    }

    private String getMethodParameters(CtMethod<?> method) {
        return getParametersAsString(method.getParameters());
    }

    private String getParametersAsString(List<CtParameter<?>> parameters) {
        return "(" + parameters.stream()
                .map(ctParameter -> ctParameter.getType().toString())
                .collect(Collectors.joining(",")) + ")";
    }

    private static String[] getPathToJunit(String path, MavenLauncher.SOURCE_TYPE testSource) {
        File file = new File(path + testSource + ".cp");
        try {
            final String cmd;
            if (System.getProperty("os.name").startsWith("Windows")) {
                cmd = "cmd /C mvn dependency:build-classpath -Dmdep.outputFile=" + path + testSource + ".cp";
            } else {
                cmd = "mvn dependency:build-classpath -Dmdep.outputFile=" + path + testSource + ".cp";
            }
            Process p = Runtime.getRuntime().exec(cmd);
            new Thread() {
                @Override
                public void run() {
                    while (p.isAlive()) {
                    }
                }
            }.start();
            p.waitFor();
            final String classpath;
            try (BufferedReader buffer = new BufferedReader(new FileReader(file))) {
                classpath = buffer.lines().collect(Collectors.joining(System.getProperty("path.separator")));
            }
            return classpath.split(System.getProperty("path.separator"));
        } catch (IOException | InterruptedException e) {
            throw new RuntimeException(e);
        }

    }

    public static void main(final String[] args) throws IOException, MavenInvocationException, XmlPullParserException {
        String absPath = System.getProperty("absPath");
        reportPath = System.getProperty("reportPath");
        new InvokeMaven(absPath).run();
        new TestVisibilityChecker(absPath).run();

//        CSVWriter writer = new CSVWriter(new FileWriter(reportPath + "zzz_successful_project.csv",
//                true));
//
//        writer.writeNext(new String[]{String.valueOf(absPath.split("/")[absPath.split("/").length - 1]),
//                    String.valueOf(Instant.now())});
    }
}