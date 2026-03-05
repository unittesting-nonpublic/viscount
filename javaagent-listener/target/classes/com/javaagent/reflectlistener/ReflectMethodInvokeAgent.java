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

        String cut = agentOps.split("_whynotutopia_")[0];
        String test = agentOps.split("_whynotutopia_")[1];
        inst.addTransformer(new ReflectMethodInvokeTransformer(cut,test),true);
    }
}