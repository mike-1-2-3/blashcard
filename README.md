#Blashcards

A bash script that gives out flashcards. Now you can keep your notes in a quizzable, searchable, format!

##Basic Use

Say you downloaded the script and two example files into your current directory. You could make it ask you all of the questions with ./blashcards.sh linux.cards history.cards

To make your own cards, simply make a text file of this format:

Q: Knock knock?  
A: Who's there?  

Q: Network classes?  
A: A - 0  
B - 10  
C - 110  
D - 1110  
E - 1111  

##More examples

* To find out what sections are in the linux file, run ./blashcards.sh -p linux.cards
* To ask questions just about systemd and greek history, run ./blashcards.sh linux.cards -s systemd history.cards -s greek
* Optional installation: 1. chmod 0555 blashcards.sh 2. sudo mv blashcards.sh /usr/local/bin
This step will allow you to open your cards file anywhere using blashcards.sh instead of /path/to/blashcards.sh.

If you make sets that others may find useful, I'd be happy to add them to this repository!