package org.example;

public class Wallet {
    private String cards[];
    private int size;

    public Wallet(int initialCapacity) {
        cards = new String[initialCapacity];
        size = initialCapacity;
    }

    public void addCard(String card) {
        if (size == cards.length) {
            resize();
        }
        cards[size] = card.toString();
    }

    private void resize() {
        String temp[] = new String[cards.length + 1];
        for (int i = 0; i < cards.length; i++) {
            temp[i] = cards[i];
        }
        size++;
        cards = temp;
    }

    public int size() {
        return size;
    }
}