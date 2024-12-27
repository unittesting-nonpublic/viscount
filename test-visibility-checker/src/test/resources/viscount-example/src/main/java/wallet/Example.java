package wallet;

public class Example {
    public static void main(String[] args) {
        Wallet wallet = new Wallet(2);
        wallet.addCard(new Card("VISA", 1234));
        wallet.addCard(new Card("Master Card", 5678));
        wallet.addCard(new Card("AMEX", 9999));
        System.out.println("Wallet size = " + wallet.size());
        System.out.println("Wallet = " + wallet.toString());
    }
}