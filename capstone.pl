#!/bin/perl
#
#opens the file of the one given in the invocation arguments
if (@ARGV){
	$_ = @ARGV[0];
	#$success = open FH, '>', $_;
}

#creates a default file for the user
else {
	print "You did not enter a filename to be worked with so there has been one created for you. It is \"newFile.txt\".\n";
	@ARGV[0] = "newFile.txt";
}	

&Menu;
$input = <STDIN>;
chomp($input);

#allows user to press Ctrl-D or x
while($input ne undef){
	$_ = $input;
	if (/^p$/i){
		&P;	#calls the print subroutine if p matches
	} 
	if (/^a$/i){
                &A;	#calls the add subroutine if a matches
        }
	if (/^s$/i){
                &S;	#calls the search subroutine if s matches
        }
	if (/^d$/i){
                &D;	#calls the delete subroutine if d matches
        }
	if (/^x$/i){
                &X;	#calls the exit subroutine if x matches
        }
	&Menu;		#restates the menu
	$input = <STDIN>;
	chomp($input);
}

#the menu
sub Menu{
	print "MENU\n";
        print "=========================\n";
        print "(p, P) Print users info\n";
        print "(a, A) Add new user\n";
        print "(s, S) Search user\n";
        print "(d, D) Delete user\n";
        print "(x, X) Exit\n";
        print "Enter your choice: ";
}

#print subroutine
sub P{
	my (@first, @last, @username);
	my $i;
	&OpenFile;	#opens the file	
        #loops through the file given         
	while (<FH>){
		chomp;
		#makes all uppercase
		s/($_)/\U$1/gi;
		#splits all the data to put into their respective arrays
		my @data = split /:/, "$_";
		push @first, @data[0];
		push @last, @data[1];
		push @username, @data[2];
	}

	#sets temp arrays that way we can delete data from them in &Min
	@tempUsername = @username;
	@tempFirst = @first;
	@tempLast = @last;

	&Min;		#calls the min to sort all the data
	
	#loops through the array to print all data in a nicely tabbed format
	foreach (@sortedUsername){
		chomp;
		print "@sortedUsername[$i]\t@sortedFirst[$i]\t@sortedLast[$i]\n";
		$i++;
	}
	#clears the list so they are empty if the subroutine gets ran again	
	@sortedFirst = ();
	@sortedLast = ();
	@sortedUsername = ();

	close FH;	#closes the file
}
#add subroutine
sub A{
	my (@first, @last);
 	&OpenFile;	#opens the file
	#asks the user for the first name
	print "Please enter the first name of the new user.\n";
	$firstname = <STDIN>;
	#asks the user for the last name
	print "Please enter the last name of the new user.\n";
	$lastname = <STDIN>;
	chomp($firstname);
	chomp($lastname);
	#loops through the file given
	while (<FH>){
		chomp;
		#splits all the data to put into their respective arrays
		my @data = split /:/, "$_";
		push @first, @data[0];
		push @last, @data[1];
		push @username, @data[2];
	}
	#split the names into character arrays in order to make the username
	my @charfirst = $firstname =~ /./sg;
	my @charlast = $lastname =~ /./sg;
	close FH;	#closes the file
	&OpenFileToAppend;	#opens the file
	my $i = 0;
	#adds firstname character
	$username = @charfirst[0];
	#builds the username
	while ($i <= 3){
		#adds upto the first 4 letters of the last name
		if (@charlast){
			$username .= @charlast[$i];
		}
		$i++;		#increments the index
	}
	&Check;		#searches the username array to see if the username exists already
	#searches the username array to see if the username exists already
	while ($check == 1){
		$username .= "1";	#adds a 1 if the username already exists
		&Check;
	}
	
	#makes all the data uppercase for the new user		
	$firstname =~ s/($firstname)/\U$1/i;
	$lastname =~ s/($lastname)/\U$1/i;
	$username =~ s/($username)/\U$1/i;
	
	#appends it to the file 
	print FH "$firstname:$lastname:$username\n";
	$username = "";
	close FH;	#closes the file
}

#search subroutine
sub S{
	my (@first, @last, @username);
	&OpenFile;	#opens the file
	#asks the user for the name to be searched for
	print "Please enter the first name of the user to search for.\n";
        $input = <STDIN>;       #gets the name from the user
        chomp($input);
	#loops through the file given
	while (<FH>){
                chomp;
                #splits all the data to put into their respective arrays
                my @data = split /:/, "$_";
                push @first, @data[0];
                push @last, @data[1];
                push @username, @data[2];
        }
	#checks if the array is empty which also sees if the file in turn is empty
	if (@first){	
		my $i;
		#loops through the array until it finds the name or reaches the end of the array
		foreach (@first){
			#sees if it is equal to the $_
			if (/^($input)$/i){
				print "@username[$i]\t@first[$i]\t@last[$i]\n";
				close FH;	#closes the file
				return;
			}
			$i++;		#increment the index				
		}
		print "The name is not in the file\n";
	}
	else {
		print "The file is empty\n";
	}
        close FH;	#closes the file        
}

#delete subroutine
sub D{
	my (@first, @last, @username);
	&OpenFile;	#opens file
	#asks the user for the name to be deleted
	print "Please enter the first name of the user to be deleted.\n";
	$input = <STDIN>;	#gets the name from the user
	chomp($input);		
	#loops through the file given
	while (<FH>){
		chomp;
		#splits all the data to put into their respective arrays
	        my @data = split /:/, "$_";
	        push @first, @data[0];
	        push @last, @data[1];
	        push @username, @data[2];
	}
	close FH;		#closes the file
	#checks if the file is empty
	if (@first){
		my ($i, $count);
		#loops through to see if the name is in the file
		foreach (@first){
			#checks to see if the name matches
			if (/^($input)$/i){
				&OpenFileToWrite;	#opens the file to overwrite
				#removes all the data for the matching name
				splice(@first, $i, 1);
				splice(@last, $i, 1);
				splice(@username, $i, 1);
				print "The user was deleted\n";
				#loops through to print to the file
				foreach (@first){
					print FH "@first[$count]:@last[$count]:@username[$count]\n";
					$count++;
				}
				close FH;	#closes the file
				return;
			}	
			$i++;		#increment the index
		}
		print "That name is not in the file\n";
	}
	else{
		print "There are no entries in the file\n";
	}
	
	close FH;	#close the file	
}

#exit subroutine
sub X{
	#kills the program
	die "You pressed exit\n";	
}

#opens the file to read from it
sub OpenFile{
	#only opens the first file if user provides more than one filename
	$_ = @ARGV[0];
	#opens file for reading
	open FH, '<', $_;
}

#opens the file for appending to it
sub OpenFileToAppend{
	#only opens the first file if user provides more than one filename
	$_ = @ARGV[0];
	#opens file for appending
	open FH, '>>', $_;
}

#opens the file to write to it
sub OpenFileToWrite{
	#only opens the first file if user provides more than one filename
	$_ = @ARGV[0];
	#opens file for writing
	open FH, '>', $_;
}

#find the minimum username
sub Min{
	#checks if the array is empty already
	&IsEmpty;
	if($result == 0){
		print "There are no users in the database.\n";
	}
	$size = $#tempUsername+1;
	#loops through until the tempUsername array is empty through &IsEmpty
	while($result != 0){
		#reset basic variables
		$current = @tempUsername[0];
	 	my $count = 1;
		#loops through all the elements in @tempUsername
		while ($count < $size){
			#compares the current string with the least valued element thus far
			if(@tempUsername[$count] lt $current){
				$current = @tempUsername[$count];	#sets the current to the $_
				$index = $count;	#sets the index to the value of the count
			}
			$count= $count +1;		#increment count		
		}
			
		#splice each of the temp arrays at the same index
		$u = splice(@tempUsername, $index, 1);
		$f = splice(@tempFirst, $index, 1);
		$l = splice(@tempLast, $index, 1);
	 	if($size == 0){
			#splice each of the temp arrays at the same index
                	$u = splice(@tempUsername, 0);
                	$f = splice(@tempFirst, 0);
                	$l = splice(@tempLast, 0);                                                
		}
		#push all the spliced elements into the respective sorted arrays
		push @sortedUsername, $u;
		push @sortedFirst, $f;
		push @sortedLast, $l; 
		$size--;
		$index = 0;
		&IsEmpty;
	}
}
#checks if the tempUsername array is empty
sub IsEmpty{
	#if the array is not empty it returns 1
	if(@tempUsername){
		$result = 1;
	}
	#if the array IS empty it returns 0
	else {
		$result = 0;
	}
}

#sees if the username matches any of the usernames already in the array
sub Check{
	#loops through to see if the username already exists
	foreach (@username){
		my $i;
		#compares them no matter the capitalization
		if (/^($username)$/i){
			$check = 1;
                	return;
		}
                $i++;           #increment the index
	}
	$check = 0;
}
