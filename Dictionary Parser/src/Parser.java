package src;

/*
 * Dictionary file format: IMPORTANT : First Line must be empty. Each line after is a word.
 * Output file format: IMPORTANT : Each line from first is a word, ends with an empty line.
 */

import java.io.*;
import java.util.*;

public class Parser {
	/*
	 * @param fileName, the library file to parse; first line is blank
	 * @param newFiles, map from String to List of Strings
	 * @effects fills newFiles map from first two letters to the List of words that starts with them
	 * @effects create dictionary files with words starting with the same first two letters; last line is blank
	 */
	public static void parseFile(String fileName, Map<String, List<String>> newFiles) throws Exception {
		BufferedReader reader = null;
		
		try {
			reader = new BufferedReader(new FileReader(fileName));
			System.out.println("File open successful!");
			
			String word;
			
			while ((word = reader.readLine())!= null){
				String twoLetter = word.substring(0,2);
				
				if (!newFiles.containsKey(twoLetter)) {
					newFiles.put(twoLetter, new ArrayList<String>() );
				
					//Deletes and recreate file with only first word with the twoLetter String
					PrintWriter out1 = new PrintWriter(new FileWriter(twoLetter+".txt"));
					out1.println(word);
					out1.close();
					System.out.println("(Re)Constructing file: "+twoLetter+".txt");
						
				} else {
					//Append mode, adds a word in a new line
					BufferedWriter out2 = new BufferedWriter(new FileWriter(twoLetter+".txt", true));
					out2.append(word);
					out2.newLine();			
					out2.close();
				} newFiles.get(twoLetter).add(word);
			}
		} catch (IOException e) {
			System.err.println(e.toString());
			e.printStackTrace(System.err);
		} finally {
			if (reader != null) {
				reader.close();
				System.out.println("File Reader Closed.");
			}
		}
	}
}
