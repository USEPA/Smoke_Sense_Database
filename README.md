
# Smoke Sense (Database)

Smoke Sense is a mobile platform where users can submit health symptoms and learn more about how fire smoke can affect one's health.

# Getting Started

To complete database setup, you'll simply need to run the scripts in SQL Server Management Studio as a user that has full admin permissions. A few key instructions are as follows:

## Prerequisites

1. Before running scripts, please change the database name to your desired database name in the following places (currently the database in the scripts is referenced as **[SmokeSense_MyTest1]**):
    1. Script 1 - line 3
    2. Script 5 = line 58, and you can also change the job name on line 21 if desired
    3. Script 10 - lines 7, 11, 15, 19

# Directions

1. Please run scripts in order (they are numbered), as each script builds upon the prior scripts
2. Please run each script while pointed to the database created in script 1 (except for script 1 of course, which can be run while pointed pretty much anywhere).
    1. You can do this by selecting the proper database name from the dropdown in SQL Server Management Studio, or by adding a line that reads `USE [YOUR-DATABASE-NAME]` with the database name in brackets at the top of each script.
    2. Scripts 5 and 10 will run against the msdb and master databases; these scripts include the proper `USE [msdb]` and `USE [master]` statements; no adjustments on your end are required
3. Script 10 creates the default SmokeSense user. You are welcome to complete setup and make sure everything is working with the default password in place. However, we do recommend changing the password from the default one on both the database and API side after initial installation and testing.
4. The scripts include a default statement about backing up your database before running them; since you are creating a database from scratch, you don't need to worry about this!
5. If you have any questions, just reach out to SonomaTech at smokesenseteam@sonomatech.com! We will be available for assistance.
