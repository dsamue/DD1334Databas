#!/usr/bin/python
import pgdb
from sys import argv
#  Here you shall complete the code to allow a customer to use this interface to check his or her shipments.
#  You will fill in the 'shipments' funtion 

#  The code should not allow the customer to find out other customers or other booktown data.
#  Security is taken as the customer knows his own customer_id, first and last names.  
#  So not really so great but it illustrates how one would check a password if there were the addition of encription.

#  Most of the code is here except those little pieces needed to avoid injection attacks.  
#  You might want to read up on pgdb, postgresql, and this useful function: pgdb.escape_string(some text)

#  You should also add exception handling.  Search WWW for 'python try' or 'exception' for things like:
#         try: 
#             ...
#         except (errorcode1, errorcode2,...):
#             ....
# A good tip is the error message you get when exceptions are not caught such as:
#  Traceback (most recent call last):
#  File "./customerInterface.py", line 105, in <module>
#    db.run()
#  File "./customerInterface.py", line 98, in run
#    actions[self.print_menu()-1]()
#  File "./customerInterface.py", line 68, in shipments
#    self.cur.(query)
#  File "/usr/lib/python2.6/dist-packages/pgdb.py", line 259, in execute
#    self.executemany(operation, (params,))
#  File "/usr/lib/python2.6/dist-packages/pgdb.py", line 289, in executemany
#    raise DatabaseError("error '%s' in '%s'" % (msg, sql))
# pg.DatabaseError: error 'ERROR:  syntax error at or near "*"
# LINE 1: SELECT * FROM * WHERE *
#
#  You should think "Hey this pg.DatabaseError (an error code) mentioned above could be caught at 
#  File "./customerInterface.py", line 68, in shipments  self.cur.execute(query) also mentioned above."
#  The only problem is the codes need to be pgdb. instead of the pg. shown in my output 
#  (I am not sure why they are different) so the code to catch is pgdb.DatabaseError.
#
#
class DBContext:
    """DBContext is a small interface to a database that simplifies SQL.
    Each function gathers the minimal amount of information required and executes the query."""

    def __init__(self): #PG-connection setup
        print("AUTHORS NOTE: If you submit faulty information here, I am not responsible for the consequences.")

        print "The idea is that you, the authorized database user, log in."
        print "Then the interface is available to customers whos should only be able to see their own shipments."
        params = {'host':'nestor2.csc.kth.se', 'user':raw_input("Username: "), 'database':'', 'password':raw_input("Password: ")}
        self.conn = pgdb.connect(**params)
        self.menu = ["Shipments Status", "Exit"]
        self.cur = self.conn.cursor()
    def print_menu(self):
        """Prints a menu of all functions this program offers.  Returns the numerical correspondant of the choice made."""
        for i,x in enumerate(self.menu):
            print("%i. %s"%(i+1,x))
        return self.get_int()

    def get_int(self):
        """Retrieves an integer from the user.
        If the user fails to submit an integer, it will reprompt until an integer is submitted."""
        while True:
            try:
                choice = int(input("Choose: "))
                if 1 <= choice <= len(self.menu):
                    return choice
                print("Invalid choice.")
            except (NameError,ValueError, TypeError,SyntaxError):
                print("That was not a number, genious.... :(")
 
    def shipments(self):
        # These input funtions are not correct so  exceptions caught and handled.
        # ID must be integer
        while True:
            try:  
                ID = int(raw_input("customerID: "))
                break
            except (NameError,ValueError, TypeError,SyntaxError):
                print("That was not a number, try again.")
        # Escape_string to avoid injection attacks.
        fname = pgdb.escape_string(raw_input("First Name: ").strip())
        lname = pgdb.escape_string(raw_input("Last Name: ").strip())
        
        #---Ask for the user  
        query = "SELECT * FROM customers WHERE customer_id = '%i' AND first_name ='%s' AND last_name='%s'"%(ID, fname, lname)
        print query

        #NEED TO Catch excemptions ie bad queries  (ie there are pgdb.someError type errors codes)
        try:
            self.cur.execute(query)
        except (NameError,ValueError, TypeError,SyntaxError):
            print('Opps, something went wrong with the query..')

        #--Check if user exsists (if there is any query-response)
        try:
            response = self.cur.fetchall()
            # Error if no tuples in response
            response[0][0]
            print('User found!')
            query ="SELECT shipment_id, ship_date, shipments.isbn, title FROM shipments, customers, books, editions WHERE shipments.isbn = editions.isbn AND editions.book_id = books.book_id AND shipments.customer_id = customers.customer_id AND shipments.customer_id = '%i' AND first_name = '%s' AND last_name = '%s';"%(ID,fname,lname)

        except (TypeError, IndexError):
            print "Sorry, user not found.."
            return
       
        #--Ask for shipments
        try:
            self.cur.execute(query)
        except (NameError,ValueError, TypeError,SyntaxError):
            print('Opps, something went wrong with the query..')

        self.print_answer()

    def exit(self):    
        self.cur.close()
        self.conn.close()
        exit()

    def print_answer(self):
            print("\n".join([", ".join([str(a) for a in x]) for x in self.cur.fetchall()]))

    def run(self):
        """Main loop.
        Will divert control through the DBContext as dictated by the user."""
        print 'in run'
        actions = [self.shipments, self.exit]
        while True:
            try:
                actions[self.print_menu()-1]()
            except IndexError:
                print("Bad choice")
                continue

if __name__ == "__main__":
    db = DBContext()
    db.run()
