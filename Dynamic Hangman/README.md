# DynamicHangman
CPSC 221 Programming Project #3: Dynamic Hangman

README.txt file documenting a CPSC 221 programming project.

Please fill out each TODO item in the header but change nothing else,
particularly nothing before the colon ":" on each line!

=================== HEADER =======================

Student #1, Name: Daeyoung
Student #1, ugrad.cs.ubc.ca login: e2x8
Student #1, ID: 38380127

Student #2, Name: NONE
Student #2, ugrad.cs.ubc.ca login: NONE
Student #2, ID: NONE

Team name (for fun!): TEAM ARONE

Project: DynamicHangman

Acknowledgment that you understand and have followed the course's
collaboration policy (READ IT at
http://www.ugrad.cs.ubc.ca/~cs221/current/syllabus.shtml#conduct):

Signed: DAEYOUNG DANIEL KIM

=================== BODY =======================

Plese fill in each of the following:

Approximate hours on Milestone: 4

Approximate hours on Final Submission: 5

Acknowledgment of assistance (per the collab policy!): NONE

For teams, rough breakdown of work: ALL ME

What's the most useful tool or idea you learned on this project? 

iterator, ::, namespace

What was the most frustrating issue to resolve on this project? 

Figuring out how the whole code and iterators worked.



======================= Project Details =======================

Incomplete Code

    Finish the code for get_words_by_length in evil_hangman_utils.cc and find_matching_words in word_set.cc
Buggy Code

    Debug the code for extract_pattern, generate_wordset_from_pattern and generate_new_wordset in word_set.cc generate_new_wordset calls on buggy methods, but it also contains an important bug that can cause segementation faults.

Code Evil Hangman:

    1. When a guess is entered, the game creates the set of all possible patterns generated from the current pool of words based on that guess and associates each word with its respective pattern (which may be the same as the old pattern, if the word doesn't have the guessed character).
    2. The game chooses the pattern with the largest pool of words, whether that pattern includes the guessed character or not.
    3. In cases where multiple patterns have the same pool of words, the game chooses the pattern that comes alphabetically first (i.e., first according to C++'s string comparison and so "lexicographically" first).

Just for fun (because it's actually surprisingly straightforward as long as you can find a good wordlist!): you might want to design a foreign language Evil Hangman. For languages with huge character sets, consider using transliteration alphabets (e.g., pinyin or zhuyin for Chinese characters). Yushu Lin and Steve Wolfman
2014/10/26 
