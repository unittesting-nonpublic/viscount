package org.example;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import java.lang.reflect.*;

public class WalletTest {
    @Test
    public void testAddCard() {
        Wallet wallet = new Wallet(2);
        wallet.addCard("VISA");
        wallet.addCard("Master Card");
        wallet.addCard("AMEX");
        assertEquals(5, wallet.size());
    }

    @Test
    public void testResize() throws Exception {
        Wallet wallet = new Wallet(2);
        Method method = wallet.getClass().getDeclaredMethod("resize");
        method.setAccessible(true);
        method.invoke(wallet);
        assertEquals(3, wallet.size());
    }
}
