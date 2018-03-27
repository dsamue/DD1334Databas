#!/usr/bin/python

# Lines that start as this one does are comments and have no effect on
# the execution of the program.  (Most added by John Folkesson to help
# understand the code.)

# When you import the pgdb  module, all the
# classes and functions in that module become available for you to
# use.  For example you can now use the pgdb.connect() function to
# establish a connection to your copy of the database. 

# Possibly helpful example code is found at:
# https://wiki.inf.ed.ac.uk/twiki/pub/DatabaseGroup/TeachingPythonPostgreGuide/dbexample.py.txt

import pgdb
from sys import argv

# we define a class that we will use in our main program
class DBContext:
    """DBContext is a small interface to a database that simplifies SQL.
    Each function gathers the minimal amount of information required and executes the query."""

# we first define the class, its definitions, functions attributes,
# members ... what ever you like to call this stuff.  Then way down at
# the bottom of this file we will create on of these.
# this __init___ operation is automatically called when the object is created.

    def __init__(self): #PG-connection setup
        print("AUTHORS NOTE: If you submit faulty information here, I am not responsible for the consequences.")

# we need to call the connect function with the right parameters some
# of wheich we 'hard code here such as the host, wnd others we call
# the built in python function raw_input to get from the user.  All are stored in a variable that we chose to call params.
        params = {'host':'nestor2.csc.kth.se', 'user':raw_input("Username: "), 'database':raw_input("Database: "), 'password':raw_input("Password: ")}
        self.conn = pgdb.connect(**params)
        # Here we create an attribute of our class (DBContex) called
        # menu as a list of strings.
        self.menu = ["Select.", "Insert.", "Remove.", "Exit"]
        # Here we create a cursor (see chap 9) and
        # http://www.python.org/dev/peps/pep-0249/
        self.cur = self.conn.cursor()

# Here we define a member function that we can later call repeatidly
    def print_menu(self):
        """Prints a menu of all functions this program offers.  Returns the numerical correspondant of the choice made."""
        for i,x in enumerate(self.menu):
            print("%i. %s"%(i+1,x))
            # this get_int function is defined below
        return self.get_int()

    def get_int(self):
        """Retrieves an integer from the user.
        If the user fails to submit an integer, it will reprompt until an integer is submitted."""
        while True:
            # we go round here untill we get to return (ie while True)

          #  The try statement works as follows.  First, the try
          #  clause (the statement(s) between the try and except
          #  keywords) is executed. If no exception occurs, the except
          #  clause is skipped and execution of the try statement is
          #  finished. If an exception occurs during execution of the
          #  try clause, the rest of the clause is skipped. Then if
          #  its type matches the exception named after the except
          #  keyword, the except clause is executed, and then
          #  execution continues after the try statement.  If an
          #  exception occurs which does not match the exception named
          #  in the except clause, it is passed on to outer try
          #  statements; if no handler is found, it is an unhandled
          #  exception and execution stops with a message as shown
          #  above.
            try:
                # an Error here (ie wrong input type) jumps to except
                choice = int(input("Choose: "))
                if 1 <= choice <= len(self.menu):
                    return choice
                # here we had a number but it was out of range
                print("Invalid choice.")
            except (NameError,ValueError, TypeError, SyntaxError):
                print("That was not a number, genious.... :(")

                # This function will be called if the user choses select.
    def select(self):
        """Finds and prints tuples.
        Will query the user for the information required to identify a tuple.
        If the filter field is left blank, no filter will be used."""
        # raw_input returns the entire line entered at the promt. The
        # split(",") method then creates a list of the relations
        # (tables) that you have separated by commas.  The strip
        # method just remove the white space.  So this line is read
        # from right to left, that is first the user input is parsed
        # into a list of names, then the x is set to the list contents
        # incremented thru the list then the current x is striped and
        # the words " natural join " are added to the long string
        # being defined and stored in the variable tables.

        tables = [x.strip() + " natural join " for x in raw_input("Choose table(s): ").split(",")]

# Here we do some char pointer tricks to remove the extra " natural
# join " (14 characters
        tables[len(tables)-1] = tables[len(tables)-1][0:len(tables[len(tables)-1])-14]
# pring the result to the screen
        print tables
# here columns becomes the string that you type at prompt for Choose columns.
        columns = raw_input("Choose column(s): ")
        print columns
        #list comprehension building a list ready to be reduced into a string.
        filters = raw_input("Apply filters: ")
        # This will set query to the long string "SELECT columns FROM
        # tables WHERE filters;" The %s indicate that a string from a
        # variable will be inserted here, Those string variables
        # (actually expressions here) are then listed at the end
        # separated by commas.

        # lambda is a python keyword for defining a function (here with a+b)
        # reduce is a python built in way to call a function on a list 
        #   (iterable) (here each element of columns is taken as b in turn 
        # join is the python way to concatenate a list of strings
        try:
            query = """SELECT %s FROM %s%s;"""%(reduce(lambda a,b:a+b,columns), "".join(tables), "" if filters == "" else " WHERE %s"%filters)
        except (NameError,ValueError, TypeError,SyntaxError):
            print "  Bad input."
            return
        print(query)
        # Here we do the select query at the cursor
        # No errors are caught so this crashes horribly on malformed queries
        self.cur.execute(query)       
        # This function is defined below
        self.print_answer()
        #OK now you do the next two:
    def remove(self):
        """Removes tuples.
        Will query the user for the information required to identify a tuple.
        If the filter field is left blank, no filters will be used."""
        #Ok, vi behover fa tables och Where-sats. 
        table = raw_input("Choose table: ")
        print table

        filters = raw_input("Apply filters: ")
        print filters

        try:
            query = """DELETE FROM %s WHERE (%s);"""%(table, filters)
        except (NameError,ValueError, TypeError,SyntaxError):
            print "  Bad input."
            return

        print query
        self.cur.execute(query)

        pass

    def insert(self):
        """inserts tuples.
        Will query the user for the information required to create tuples."""
        """Ok, so vi beover veta table och varden"""

        table = raw_input("Choose table: ")
        print table

        values = raw_input("Type value(s): ")
        print values

        try:
            query = """INSERT INTO %s VALUES (%s);"""%(table, values)
        except (NameError,ValueError, TypeError,SyntaxError):
            print "  Bad input."
            return

        print query
        self.cur.execute(query)
        pass   

    def exit(self):    
        self.cur.close()
        self.conn.close()
        exit()
    
    def print_answer(self):
# We print all the stuff that was just fetched.
            print("\n".join([", ".join([str(a) for a in x]) for x in self.cur.fetchall()]))

    # we call this below in the main function.
    def run(self):
        """Main loop.
        Will divert control through the DBContext as dictated by the user."""
        actions = [self.select, self.insert, self.remove, self.exit]
        while True:
            try:
                # So this is executed right to left, The print_menu
                # function is run first (defined above), then the
                # return value is used as an index into the list
                # actions defined above, then that action is called.
                actions[self.print_menu()-1]()
                print
            except IndexError:
# if somehow the index into actions is wrong we just loop back
                print("Bad choice")

# This strange looking line is what kicks it all off.  So python reads until it sees this then starts executing what comes after-
if __name__ == "__main__":
    db = DBContext()
    db.run()
