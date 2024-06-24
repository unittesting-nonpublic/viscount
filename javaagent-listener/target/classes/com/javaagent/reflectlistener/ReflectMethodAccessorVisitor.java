package com.javaagent.reflectlistener;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;

public class ReflectMethodAccessorVisitor implements InvocationHandler {
    private Object target;

    public ReflectMethodAccessorVisitor() {
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        // Perform custom actions before the method call (if needed)
        System.out.println(Thread.currentThread().getStackTrace());
        Object result = method.invoke(target, args);

        // Perform custom actions after the method call (if needed)

        return result;
    }
}
