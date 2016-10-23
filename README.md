# CreateSheetWithContacts
An Applescript to create a Numbers sheet from a defined contacts group.  
To be used with 'Pages Data Merge'.
This script is part 1 of a scripting scenario to create bills for courses. 

##Creating bills
I have a group of contacts (students) for which I want to make bills in Pdf documents and send them with mail.
* The first step is to create a NUmbers document with the data.  
* The next step is to create by hand a Pages document containing the (merge) fields.  
* The last step is to use the application ['Pages Data Merge'](https://iworkautomation.com/pages/script-tags-data-merge.html) 

## Dutch remarks
The script has Dutch remarks and Dutch fields, also the Formulas in Numbers are in Dutch. 

## Extra contact fields
The script gets all contacts in group 'Leerlingen'.
Every 'leerling' has extra fields added to their contacts sheet: Five extra fields 'Related Names' with these descriptions: 'Lesgeld', 'Lesfrequentie', 'Lescode', 'Lesduur', 'Lesdag'. These fields are also part of the contacts template and are synced with iCloud.

These extra fields provide the students payment data needed in the Numbers sheet.


