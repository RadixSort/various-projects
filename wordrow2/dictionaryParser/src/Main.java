package src;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public final class Main {
	public static void main(String[] Args){
			Map<String, List<String>> newFiles = new HashMap<String, List<String>>();
			
			try {
				String fileName = "dict.txt";
				Parser.parseFile(fileName, newFiles);
				System.out.println("Parsing Done.");
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
}