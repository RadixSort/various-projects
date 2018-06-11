package com.binlab.wordrow.word;

import java.io.BufferedReader;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.util.Scanner;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.files.FileHandle;

public class WordManager {

	/**
	 * @param args
	 * @throws IOException 
	 */
	
	private int[] startIndex;
	private int[] endIndex;
	private FileHandle fileRead;
	
	/** Constructor. Initializes startindex and endindex values for two letter
	 * combinations starting from "aa" going to "zz".
	 * 
	 */
	public WordManager() throws IOException,FileNotFoundException {
		// TODO Auto-generated method stub
		String line = null;
		int linecount = 0;
		int findcount = 1; 
		int tlettcount = 0;
		int flettcount = 0;
		StringBuilder duoL = new StringBuilder("aa");
		boolean read = true;
		char[] chars = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
		startIndex = new int[676];
		endIndex = new int[676];
		Scanner reader = new Scanner(System.in);
		
		
		int startind = 0;
		int endind;
		int duoLval;
		
		
		fileRead = Gdx.files.internal("data/dict.txt");
		BufferedReader buffR = new BufferedReader(fileRead.reader());
		
		line = buffR.readLine();
		while(line != null){

			if(read){
				linecount++;
				line = buffR.readLine();
			}
			
			if(line == null){
				break;
			}
			if(line.charAt(0) == duoL.charAt(0) && line.charAt(1) == duoL.charAt(1)){
				findcount++;
				read = true;
			}
			else if(tlettcount == 25){
				duoLval = getduoLVal(duoL.charAt(0), duoL.charAt(1));
				endind = linecount - 1;
				startIndex[duoLval] = startind;
				endIndex[duoLval] = endind;
				startind = linecount;
				tlettcount = 0;
				duoL.deleteCharAt(0);

				flettcount++;
				duoL.insert(0,chars[flettcount]);
				tlettcount = 0;
				duoL.deleteCharAt(1);
				duoL.insert(1, chars[tlettcount]);
				findcount = 0;
				read = false;
			}
			else{
				duoLval = getduoLVal(duoL.charAt(0), duoL.charAt(1));
				endind = linecount - 1;
				startIndex[duoLval] = startind;
				endIndex[duoLval] = endind;
				startind = linecount;
				
				
				tlettcount++;
				duoL.deleteCharAt(1);
				duoL.insert(1, chars[tlettcount]);
				findcount = 0;
				read = false;
			}
		}

		System.out.println(duoL + ": " + findcount + ", " + linecount);
		System.out.println(linecount);
		buffR.close();

	}
	
	public boolean isValidWord(String string, String fileN) throws IOException{
		string = string.toLowerCase();
		
		fileRead = Gdx.files.internal("data/dict.txt");
		BufferedReader buffR = new BufferedReader(fileRead.reader());
		
		if(string.length() < 2){
			return false;
		}
		
		//Temporary value stored in endline to use as index
		int startline;
		int endline = getduoLVal(string.charAt(0),string.charAt(1));
		
		startline = startIndex[endline];
		endline = endIndex[endline];
		
		int linecount = 0;
		String line = buffR.readLine();
		while(line!=null){
			if(linecount >= startline && linecount <= endline){
				if(string.equals(line)){

					System.out.println(string + " is a valid word.");
					return true;
				}
				else{
					line = buffR.readLine();
					linecount++;
				}
			}
			else if(linecount> endline){

				System.out.println(string + " is NOT a valid word.");
				return false;
			}
			else{
				line = buffR.readLine();
				linecount++;
			}
		}

		System.out.print(string + " is NOT a valid word.");
		return false;
	}
	
	
	//Return the array index number of the first two letters of the word to find
	private int getduoLVal(char first, char second){
		char[] chars = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
		int i = 0;
		int firstpos = 25;
		int secondpos = 25;
		for(i = 0;i<26;i++){
			if(first == chars[i]){
				firstpos = i;
			}
			if(second == chars[i]){
				secondpos = i + 1;
			}
		}
		
		int retVal = firstpos * 26 + secondpos;
		if(retVal >= 676){
			return 675;
		}
		return retVal;
		
	}
	

}

