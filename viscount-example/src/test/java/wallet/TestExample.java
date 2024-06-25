package wallet;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.lang.reflect.Method;
import org.junit.jupiter.api.Test;

public class TestExample {

    @Test
    public void testAddCard() {
        Wallet wallet = new Wallet(2);
        wallet.addCard(new Card("VISA", 1234));
        wallet.addCard(new Card("Master Card", 5678));
        wallet.addCard(new Card("AMEX", 9999));
        assertEquals(3, wallet.size());
    }

    @Test
    public void testResize() throws Exception {
        Wallet wallet = new Wallet(2);
        Method method = wallet.getClass().getDeclaredMethod("resize");
        method.setAccessible(true);
        method.invoke(wallet);
        assertEquals(4, wallet.capacity());
    }

    @Test
    public void testAddCardTwice() {
        Wallet wallet = new Wallet(1);
        wallet.addCard(new Card("VISA", 1234));
        wallet.addCard(new Card("AMEX", 9999));
        wallet.addCard(new Card("AMEX", 9999));
        assertEquals(2, wallet.size());
    }

}
