package com.binlab.wordrow.word;

import java.util.HashMap;

public class ScoreManager {
	private int score;
	private int wordCombo;
	private int wordScore;
	private int lettScore;
	private int[] letterScore = {1,3,3,2,1,4,2,4,1,8,5,1,3,1,1,3,10,1,1,1,1,4,4,8,4,10};
	private HashMap<Character, Integer> lettScores;
	
	/**Constructor for score manager. Store letter values in a 
	 * hashmap and initialize user score to 0.
	 */
	public ScoreManager(){
		score = 0;
		lettScores = new HashMap<Character,Integer>();
		lettScores.put('a', 1);
		lettScores.put('b', 3);
		lettScores.put('c', 3);
		lettScores.put('d', 2);
		lettScores.put('e', 1);
		lettScores.put('f', 4);
		lettScores.put('g', 2);
		lettScores.put('h', 4);
		lettScores.put('i', 1);
		lettScores.put('j', 8);
		lettScores.put('k', 5);
		lettScores.put('l', 1);
		lettScores.put('m', 3);
		lettScores.put('n', 1);
		lettScores.put('o', 1);
		lettScores.put('p', 3);
		lettScores.put('q', 10);
		lettScores.put('r', 1);
		lettScores.put('s', 1);
		lettScores.put('t', 1);
		lettScores.put('u', 1);
		lettScores.put('v', 4);
		lettScores.put('w', 4);
		lettScores.put('x', 8);
		lettScores.put('y', 4);
		lettScores.put('z', 10);
	}
	
	/**Scores the word according to Scrabble standards.
	 * 
	 * @param word: The word that is currently on the wordrow
	 */
	public void scoreWord(String word){
		int i = word.length() - 1;
		wordScore = 0;
		while(i >= 0){
			wordScore += lettScores.get(word.charAt(i));
			i--;
		}
		score += wordScore;
		
		System.out.println(word + " is worth " + wordScore);
	}
	
	public int getScore(){
		return score;
	}
	
	/**Input the wordlength to check for wordlength bonuses.
	* @Returns a 0 if wordlength < 7
	* Returns a 1 if wordlength = 7
	* Returns a 2 if wordlength > 7
	*/
	public int checkForBonuses(int wordLength){
		if(wordLength<7)
			return 0;
		else if(wordLength == 7)
			return 1;
		else{
			return 2;
		}
	}
	
	private int getLetterScore(char letter){
		return 1;
	}
}
