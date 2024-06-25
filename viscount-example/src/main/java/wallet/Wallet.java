package wallet;

public class Wallet {
    private Card cards[];
    private int size;

    public Wallet(int initialCapacity) {
        cards = new Card[initialCapacity];
        size = 0;
    }

    public void addCard(Card card) {
        if (size == cards.length) {
            resize();
        }
        cards[size++] = card;
    }

    private void resize() {
        Card temp[] = new Card[cards.length * 2];
        for (int i = 0; i < cards.length; i++) {
            temp[i] = cards[i];
        }
        cards = temp;
    }

    public int size() {
        return size;
    }

    protected int capacity() {
        return cards.length;
    }

    public String toString() {
        String result = "";
        for (int i = 0; i < size; i++) {
            result += cards[i] + "\n";
        }
        return result;
    }

    Card latestCard() {
        return cards[size-1];
    }
}

class Card {
    private String name;
    private int number;

    public Card(String name, int number) {
        this.name = name;
        this.number = number;
    }

    public String toString() {
        return name + " " + number;
    }
}
