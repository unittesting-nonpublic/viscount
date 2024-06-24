package com.javaagent.reflectlistener;

import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.IllegalClassFormatException;
import java.security.ProtectionDomain;
import java.lang.instrument.Instrumentation;
import org.objectweb.asm.*;

class ReflectMethodInvokeMethodVisitor extends MethodVisitor {
    public ReflectMethodInvokeMethodVisitor(MethodVisitor mv) {
        super(Opcodes.ASM9, mv);
    }

    @Override
    public void visitMethodInsn(int opcode, String owner, String name,
                                String descriptor, boolean isInterface) {
//        System.out.println("Owner: " + owner);
//        System.out.println("Name: " + name);
//        System.out.println("Descriptor: " + descriptor);
        if (opcode == Opcodes.INVOKEVIRTUAL &&
                owner.equals("java/lang/reflect/Method") &&
                name.equals("invoke")) {
            // Here, you can log or perform any action when a private method is invoked using reflection.
//            StackTraceElement[] xs = Thread.currentThread().getStackTrace();
////            for (StackTraceElement x : xs){
////                    System.out.println(x.toString());
////            }
//             System.out.println("Private method invoked: " + owner + "." + name + "." + descriptor);
        } else {
            System.out.println(opcode);
        }
        super.visitMethodInsn(opcode, owner, name, descriptor, isInterface);
    }
}
