package com.javaagent.reflectlistener;

import org.objectweb.asm.*;
import java.lang.reflect.Modifier;

class ReflectMethodInvokeClassVisitor extends ClassVisitor {
    public ReflectMethodInvokeClassVisitor(ClassVisitor cv) {
        super(Opcodes.ASM9, cv);
    }

    @Override
    public MethodVisitor visitMethod(int access, String name, String descriptor,
                                     String signature, String[] exceptions) {
        MethodVisitor mv = super.visitMethod(access, name, descriptor, signature, exceptions);
        System.out.println(name + ": " + descriptor + ": " + signature);
        String methodName = "invoke";
        if(name.equals(methodName)){
            return new MethodVisitor(api, mv) {
                @Override
                public void visitCode() {
                    super.visitCode();
//                    String loggingCode = "System.out.println(\"Method invoked: \" + $methodName);";
                    StackTraceElement[] xs = Thread.currentThread().getStackTrace();
                    for(StackTraceElement x:xs) {
                        System.out.println(x.toString());
                    }
                }
            };
        }
        return mv;
    }
}