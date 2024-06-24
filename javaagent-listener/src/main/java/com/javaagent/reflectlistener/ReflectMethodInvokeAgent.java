package com.javaagent.reflectlistener;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.lang.instrument.UnmodifiableClassException;
import java.lang.instrument.Instrumentation;
import java.security.SecurityPermission;
import java.util.ArrayList;
import java.util.List;

import org.objectweb.asm.*;

public class ReflectMethodInvokeAgent {
    public static void premain(String agentArgs, Instrumentation inst) throws UnmodifiableClassException {
//        System.out.println("Starting the premain ReflectInvokeAgent");
        instrument(agentArgs,inst);
    }

    public static void agentmain(String agentOps, Instrumentation inst) throws UnmodifiableClassException {
        System.out.println("Starting the agentmain ReflectInvokeAgent");
        instrument(agentOps, inst);
    }

    /**
     * agentOps is aop target classname
     */
    private static void instrument(String agentOps, Instrumentation inst) throws UnmodifiableClassException {
        System.out.println("Starting the premain ReflectInvokeAgent" + agentOps);
        Class[] xs = inst.getAllLoadedClasses();

        String cut = agentOps.split("_whynotutopia_")[0];
        String test = agentOps.split("_whynotutopia_")[1];
        inst.addTransformer(new ReflectMethodInvokeTransformer(cut,test),true);

        for (Class x : xs) {
//            if (x.getName().equals("java.lang.reflect.Method")){
//                inst.retransformClasses(x);
//            }
//            if (x.getName().equals("java.lang.reflect.Field")) {
//                inst.retransformClasses(x);
//            }
//            if (x.getName().equals("java.lang.reflect.Constructor")) {
//                inst.retransformClasses(x);
//            }
//            System.out.println(x.getName());
        }
    }
}