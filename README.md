#Blashcards

A bash script that gives out flashcards. Now you can keep your notes in a quizzable, searchable, format!

##Basic Use

Download a zip of the repository and extract it. Enter the uncompressed directory and run  
./blashcards.sh linux.cards history.cards   
to go through all of the sample cards.

To make your own cards, simply make a text file of this format:

Q: Knock knock?  
A: Who's there?  

Q: Columns of a user crontab?   
A: -minute   
-hour   
-day of month   
-month   
-day of week   
-command to run   

##More examples

* Run ./blashcards --help for usage information.
* To find out what sections are in the linux file, run ./blashcards.sh -p linux.cards
* To only get questions about systemd and greek history, run ./blashcards.sh linux.cards -s systemd history.cards -s greek

##Optional installation
For convenience, you will probably want to:  
* Put the script somewhere in your path. /usr/local/bin/blashcards.sh is a good spot.   
* Change the group owner with chgrp <probably your primary group name> /usr/local/bin/blashcards.sh   
* Restrict permissions to the script with chmod 0050 /usr/local/bin/blashcards.sh   

If you make sets that others may find useful, I'd be happy to add them to this repository!

![screenshot](/screenshot.png?raw=true)