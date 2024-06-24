package com.javaagent.reflectlistener;

import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.IllegalClassFormatException;
import java.lang.reflect.Modifier;
import java.security.ProtectionDomain;

import javassist.*;
import javassist.expr.ExprEditor;
import javassist.expr.MethodCall;

class ReflectMethodInvokeTransformer implements ClassFileTransformer {

    String[] cuts;
    String[] tests;
    public ReflectMethodInvokeTransformer(String cut, String tests) {
//        super();
        this.cuts = cut.split(",");
        this.tests = tests.split(",");
    }

    @Override
    public byte[] transform(ClassLoader loader, String className, Class redefiningClass, ProtectionDomain domain, byte[] bytes) throws IllegalClassFormatException {
        for (String cut : cuts){
            if(className.equals(cut)){
//                if (!className.contains("$")) {
                    return transformClass(redefiningClass, bytes, "cut");
//                }
            }
        }

        for (String test : tests){
            if(className.equals(test)){
//                if (!className.contains("$")) {
                    return transformClass(redefiningClass, bytes, "test");
//                }
            }
        }
        return bytes;
    }

    private byte[] transformClass(Class classToTransform, byte[] b, String type) {
        ClassPool pool = ClassPool.getDefault();
        CtClass cl = null;
        try {
            cl = pool.makeClass(new java.io.ByteArrayInputStream(b));
            CtMethod[] methods = cl.getDeclaredMethods();
            for (int i = 0; i < methods.length; i++) {
                if (methods[i].isEmpty() == false) {
//                    methods[i].instrument(new ExprEditor() {
//                        @Override
//                        public void edit(MethodCall m) throws CannotCompileException {
//                            if (m.getClassName().equals("java.io.PrintStream") && m.getMethodName().equals("println")) {
//                                m.replace("");
//                            }
//                        }
//                    });
                    changeMethod(methods[i], type,pool);
//                    Object[] annotations = methods[i].getAnnotations();
//                    if (type.equals("test")) {
//                        for (Object annotation : annotations) {
//                            if (annotation.toString().contains("Test")) {
//                                // Add the @Test(timeout) annotation to the method
//                                String newAnnotation = String.format("@org.junit.Test(timeout = %d)", 4000);
//                                methods[i].insertBefore(newAnnotation);
//                                break;
//                            }
//                        }
//                    }
                }
            }

            CtConstructor[] constructors = cl.getDeclaredConstructors();
            for (int i = 0; i < constructors.length; i++) {
                if (constructors[i].isEmpty() == false) {
                    constructors[i].instrument(new ExprEditor() {
                        @Override
                        public void edit(MethodCall m) throws CannotCompileException {
                            if (m.getClassName().equals("java.io.PrintStream") && m.getMethodName().equals("println")) {
                                m.replace("");
                            }
                        }
                    });
                    changeConstructor(constructors[i], type, pool);
                }
            }
            b = cl.toBytecode();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        catch (Throwable t) {
            t.printStackTrace();
        }
        finally {
            if (cl != null) {
                cl.detach();
            }
        }
        return b;
    }

    private void changeMethod(CtMethod method, String type, ClassPool pool) throws CannotCompileException, NotFoundException {
        for (Object availableAnnotation : method.getAvailableAnnotations()) {
            if(availableAnnotation.toString().contains("Test") && !availableAnnotation.toString().contains("Testing")) {
                method.insertBefore("System.out.print(\"Start test: " + method.getLongName() + "\\t\");");
                method.addCatch("System.out.print(\"End test: " + method.getModifiers() + " " + method.getLongName() + "\\t\");" + "throw $e;", pool.get("java.lang.Exception"));
                method.insertAfter("System.out.print(\"End test: " + method.getLongName() + "\");");
                return;
            }
        }

        if (!method.getLongName().contains(".access$") &&
                !method.getLongName().contains(".<clinit>()") && !method.getLongName().contains(".<init>()") &&
                !method.getLongName().contains("$Proxy") && !method.getLongName().contains(".lambda$")) {
            if (type.equals("cut")) {
                StringBuilder cutBuilder = new StringBuilder();
                for (String cut : cuts) {
                    if (cutBuilder.length() > 0) {
                        cutBuilder.append(",");
                    }
                    cutBuilder.append("\"" + cut.replace("/", ".") + "\"");
                }

                StringBuilder testBuilder = new StringBuilder();
                for (String test : tests) {
                    if (testBuilder.length() > 0) {
                        testBuilder.append(",");
                    }
                    testBuilder.append("\"" + test.replace("/", ".") + "\"");
                }
                method.insertBefore("System.out.print(\"Start method call: " + method.getModifiers() + " " + method.getLongName() + "\\t\");");
                method.addCatch("System.out.print(\"End method call: " + method.getModifiers() + " " + method.getLongName() + "\\t\");" + "throw $e;", pool.get("java.lang.Exception"));
                method.insertAfter("System.out.print(\"End method call: " + method.getModifiers() + " " + method.getLongName() + "\\t\");");
            }
            else if (type.equals("test")) {
                method.insertBefore("System.out.print(\"Start test call: " + method.getModifiers() + " " + method.getLongName() + "\\t\");");
                method.addCatch("System.out.print(\"End test call: " + method.getModifiers() + " " + method.getLongName() + "\\t\");" + "throw $e;", pool.get("java.lang.Exception"));
                method.insertAfter("System.out.print(\"End test call: " + method.getModifiers() + " " + method.getLongName() + "\\t\");");
            }
        }
    }

    private void changeConstructor(CtConstructor constructor, String type, ClassPool pool) throws CannotCompileException, NotFoundException {
        for (Object availableAnnotation : constructor.getAvailableAnnotations()) {
            if(availableAnnotation.toString().contains("Test")
            ) {
                constructor.insertBefore("System.out.print(\"Start test constructor: " + constructor.getLongName() + "\\t\");");
                constructor.addCatch("System.out.print(\"End test constructor: " + constructor.getModifiers() + " " + constructor.getLongName() + "\\t\");" + "throw $e;", pool.get("java.lang.Exception"));
                constructor.insertAfter("System.out.print(\"End test constructor: " + constructor.getLongName() + "\\t\");");
                return;
            }
        }

        if (!constructor.getLongName().contains(".access$") &&
                !constructor.getLongName().contains(".<clinit>()") && !constructor.getLongName().contains(".<init>()") &&
                !constructor.getLongName().contains("$Proxy") && !constructor.getLongName().contains(".lambda$")) {
            if (type.equals("cut")) {
                StringBuilder cutBuilder = new StringBuilder();
                for (String cut : cuts) {
                    if (cutBuilder.length() > 0) {
                        cutBuilder.append(",");
                    }
                    cutBuilder.append("\"" + cut.replace("/", ".") + "\"");
                }

                StringBuilder testBuilder = new StringBuilder();
                for (String test : tests) {
                    if (testBuilder.length() > 0) {
                        testBuilder.append(",");
                    }
                    testBuilder.append("\"" + test.replace("/", ".") + "\"");
                }
                constructor.insertBefore("System.out.print(\"Start constructor call: " + constructor.getModifiers() + " " + constructor.getLongName() + "\\t\");");
                constructor.addCatch("System.out.print(\"End constructor call: " + constructor.getModifiers() + " " + constructor.getLongName() + "\\t\");" + "throw $e;", pool.get("java.lang.Exception"));
                constructor.insertAfter("System.out.print(\"End constructor call: " + constructor.getModifiers() + " " + constructor.getLongName() + "\\t\");");
            }
            else if (type.equals("test")) {
                constructor.insertBefore("System.out.print(\"Start test call: " + constructor.getModifiers() + " " + constructor.getLongName() + "\\t\");");
                constructor.addCatch("System.out.print(\"End test call: " + constructor.getModifiers() + " " + constructor.getLongName() + "\\t\");" + "throw $e;", pool.get("java.lang.Exception"));
                constructor.insertAfter("System.out.print(\"End test call: " + constructor.getModifiers() + " " + constructor.getLongName() + "\\t\");");
            }
        }
    }
}