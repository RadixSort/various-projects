package com.binlab.wordrow.word;

import java.util.ArrayList;
import java.util.List;

public class RandomStringGenerator {
	private int size = 0;

	class Frequency {
		Frequency(String str , double frequency) {
			this.str = str;
			this.frequency = frequency;
		}
		String str;
		double frequency;
	}

	private List<Frequency> letters = new ArrayList<Frequency>();

	public void addString(String str, int frequency) {
		size += frequency;
		letters.add(new Frequency(str, frequency));
	}

	public String getString() {
		double rand = Math.random() * size;	
		int incrSize = 0;
		for (int i = 0 ; i < letters.size() ; i++) {
			incrSize += letters.get(i).frequency;
			if (rand <= incrSize) {
				return letters.get(i).str;
			}
		}
		return "?";
	}

}
