package com.binlab.wordrow.word;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Scanner;

public class WordFinder {

	/**
	 * @param args
	 * @throws IOException 
	 */
	
	static int[] startIndex;
	static int[] endIndex;
	
	public static void main(String[] args) throws IOException,FileNotFoundException {
		// TODO Auto-generated method stub
		String fileN = "dict.txt";
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
		
		
		
		File fileNam = new File(fileN);
		FileReader fileR = new FileReader(fileNam);
		BufferedReader buffR = new BufferedReader(fileR);
		
		
		line = buffR.readLine();
		while(line != null){

			if(read){
				linecount++;
				line = buffR.readLine();
			}
			if(linecount == 10581 || linecount == 10582){
				System.out.println(line);
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
				System.out.println(startIndex[duoLval] + " start and end at" + endIndex[duoLval]);
				
				System.out.println(duoL + ": " + findcount + ", " + linecount);
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
				System.out.println(startIndex[duoLval] + " start and end at " + endIndex[duoLval]);
				
				System.out.println(duoL + ": " + findcount + ", " + linecount);
				
				
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
		
		
		String readString;
		
		while(true){
			System.out.print("Please enter a word: ");
			readString = reader.nextLine();
			if(findWord(readString,fileN)){
				System.out.print(readString + " is a valid word.");
			}
			else{

				System.out.print(readString + " is not a valid word.");
			}
		}
	}
	
	public static boolean findWord(String string, String fileN) throws IOException,FileNotFoundException{
		File fileNam = new File(fileN);
		FileReader fileR = new FileReader(fileNam);
		BufferedReader buffR = new BufferedReader(fileR);
		
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
					return true;
				}
				else{
					line = buffR.readLine();
					linecount++;
				}
			}
			else if(linecount> endline){
				return false;
			}
			else{
				line = buffR.readLine();
				linecount++;
			}
		}
		return false;
	}
	
	
	//Return the array index number of the first two letters of the word to find
	public static int getduoLVal(char first, char second){
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
		return retVal;
		
	}
	

}
