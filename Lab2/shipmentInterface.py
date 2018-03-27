#!/usr/bin/python
import pgdb
import datetime
from sys import argv

class DBContext:
    """DBContext is a small interface to a database that simplifies SQL.
    Each function gathers the minimal amount of information required and executes the query."""

    def __init__(self): #PG-connection setup
        print("AUTHORS NOTE: If you submit faulty information here, I am not responsible for the consequences.")

        print "The idea is that you, the authorized database user, log in."
        print "Then the interface is available to employees whos should only be able to enter shipments as they are made."
        while True:
            try:
                params = {'host':'nestor2.csc.kth.se', 'user':pgdb.escape_string(raw_input("Username: ").strip()), 'database':'', 'password':pgdb.escape_string(raw_input("Password: ").strip())}
                self.conn = pgdb.connect(**params)
                break
            except(pgdb.InternalError):
                print('Wrong password and/or username. Try again!')

        self.menu = ["Record a shipment","Show stock", "Show shipments", "Exit"]
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
 
    def makeShipments(self):
        #---Get customer id, shipment id, isbn and shipment date. Avoid insertons and catch errors. 
        #---Get customer id
        while True:
            try:
                CID = int(raw_input("customerID: "))
                break
            except(NameError,ValueError, TypeError,SyntaxError):
                print 'Input must be a number.'
       
        #---Get shipment ID
        while True:
            try:
                SID = int(input("shipment ID: "))
                break
            except(NameError,ValueError, TypeError,SyntaxError):
                print 'Input must be a number.'

        #---Get isbn        
        Sisbn = pgdb.escape_string(raw_input("isbn: ").strip())
        
        #---Get date or set today as default if no input
        while True:
            try:
                Sdate = pgdb.escape_string(raw_input("Ship date: ").strip())
                if Sdate == '':
                    Sdate = datetime.datetime.now()
                    Sdate = '%s-%s-%s'%(Sdate.year, Sdate.month, Sdate.day) 
                Sdate = datetime.datetime.strptime(Sdate, '%Y-%m-%d')
                break
            except ValueError:
                print "Incorrect data format, should be YYYY-MM-DD"

        #---Create query to get stock of choosen book 
        query ="SELECT stock FROM stock WHERE isbn = '%s';"%(Sisbn)
        print query
 
        #---Starts a new transaction (nothing to commit) - Might be unneccesary since there is a commit at the end aswell  
        self.conn.commit()

        #---Get stock of choosen book:
        try:
            self.cur.execute(query)
            stock = self.cur.fetchall()[0][0];
        except (NameError,ValueError, TypeError,SyntaxError, pgdb.DatabaseError):
            print('Opps, something went wrong with the query..')
            return
        
        #---Check if book is in stock:
        if stock < 1:
            print("No more books in stock :(")
            return
        else:
            print "WE have the book in stock"
        
        #---Create query for stock decreasement
        query="""UPDATE stock SET stock=stock-1 WHERE isbn='%s';"""%(Sisbn)
        print query
        
        #---Decrease stock but catch exceptions and rollback the transaction if there's any problem
        try:
            self.cur.execute(query)
            print "Stock decremented"
        except(NameError,ValueError, TypeError,SyntaxError, pgdb.DatabaseError):
            print('Opps, something went wrong with the query..')
            self.conn.rollback
            return

        #---Create query for new shipment
        query="""INSERT INTO shipments VALUES (%i, %i, '%s','%s');"""%(SID,CID,Sisbn,Sdate)
        print query

        #---Add to shipments but catch exceptions and rollback the transaction if there's any problem
        try:
            self.cur.execute(query)
            print "Shipment created"
        except(NameError,ValueError, TypeError,SyntaxError):
            print('Opps, something went wrong with the query..')
            self.conn.rollback
            return
        except(pgdb.DatabaseError):
            print('ERROR! Shipment ID already exsits, try again..')
            self.conn.rollback
            return


        # This ends the transaction (and starts a new one)    
        self.conn.commit()        
    def showStock(self):
        query="""SELECT * FROM stock;"""
        print query
        try:
            self.cur.execute(query)
        except (pgdb.DatabaseError, pgdb.OperationalError):
            print "  Exception encountered while modifying table data." 
            self.conn.rollback ()
            return   
        self.print_answer()
    def showShipments(self):
        query="""SELECT * FROM shipments;"""
        print query
        try:
            self.cur.execute(query)
        except (pgdb.DatabaseError, pgdb.OperationalError):
            print "  Exception encountered while modifying table data." 
            self.conn.rollback ()
            return   
        self.print_answer()
    def exit(self):    
        self.cur.close()
        self.conn.close()
        exit()

    def print_answer(self):
        print("\n".join([", ".join([str(a) for a in x]) for x in self.cur.fetchall()]))

    # we call this below in the main function.
    def run(self):
        """Main loop.
        Will divert control through the DBContext as dictated by the user."""
        actions = [self.makeShipments, self.showStock, self.showShipments, self.exit]
        while True:
            try:
                actions[self.print_menu()-1]()
            except IndexError:
                print("Bad choice")
                continue

if __name__ == "__main__":
    db = DBContext()
    db.run()
