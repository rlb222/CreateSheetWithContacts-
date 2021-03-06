use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

-- Gegevens in de stamtabel
property LesCodesTable : {{"code", "bedrag", "frequentie", "lesduur"}, {"I/V 15", "365", "twee week", "30"}, {"I/V 20", "478", "week", "20"}, {"I/V 30", "731", "week", "30"}}
property InstellingenTable : {{"Instelling", "waarde"}, {"Factuur Voorvoegsel", "1602-"}, {"Aantal Maand", "7"}, {"Periode Tekst", "januari t/m juli 2016"}, {"Betalen binnen", "14"}}

-- Veldnamen voor de Leerling gegevens
property Veldnamen : {"Voornaam", "Achternaam", "Adres", "Postcode", "Plaats", "Factuurnummer", "Factuurdatum", "niet invullen - Lescode", "Lesduur", "Lesfrequentie", "Lesgeld", "Periode_tekst", "Betaaldatum", "Mailadres"}


set Leerlingen to {}
set Leerling to {} -- temp Leerling houder



-- 
-- Vullen van een lijst met de juiste Leerling gegevens en formules
--
tell application "Contacts"
	set mijnLijst to every person in group "leerling"
	set rowTeller to 1 -- Teller van row, voor de formules, header niet meetellen
	-- Alle personen uit de lijst bij langs
	repeat with mijnPersoon in mijnLijst
		-- maak nieuw leerling record
		set Leerling to {}
		
		set end of Leerling to first name of mijnPersoon
		set end of Leerling to last name of mijnPersoon
		set end of Leerling to "Geen Straat"
		set end of Leerling to "Geen Postcode"
		set end of Leerling to "Geen Plaats"
		repeat with this_address in every address of mijnPersoon
			set item 3 of Leerling to street of this_address
			set item 4 of Leerling to zip of this_address
			set item 5 of Leerling to city of this_address
		end repeat
		set end of Leerling to "=Instellingen::$B$2&RIJ()" --thisFormula -- "Factuurnummer" --formule
		set end of Leerling to "=VANDAAG()" --formule 'today'
		set end of Leerling to (value of related names of mijnPersoon whose label is "Lescode") as text
		set end of Leerling to (value of related names of mijnPersoon whose label is "Lesduur") as text
		--		set end of Leerling to (value of related names of mijnPersoon whose label is "Lesfrequentie") as text
		set end of Leerling to ("=VERT.ZOEKEN($H" & rowTeller as text) & ";Lescodes::$A$2:$D$4;3)"
		set end of Leerling to ("=AFRONDEN.NAAR.BOVEN(VERT.ZOEKEN($H" & rowTeller as text) & ";Lescodes::$A$2:$D$4;2)×(Instellingen::$B$3÷12);0)"
		set end of Leerling to "=Instellingen::$B$4"
		set end of Leerling to "=VANDAAG()+Instellingen::$B$5" --formule today + 14 dagen
		
		-- Mail adressen
		set thisEmail to ""
		set aantalEmail to 0
		repeat with emailAddress in email of mijnPersoon
			if aantalEmail > 0 then
				set thisEmail to thisEmail & ", "
			end if
			set thisEmail to thisEmail & value of emailAddress
			set aantalEmail to aantalEmail + 1
		end repeat
		set end of Leerling to thisEmail -- alle mailadressen
		
		--
		-- Voeg dit record toe aan de lijst
		--
		if item 8 of Leerling is not "" then -- Alleen toevoegen als er een lescode beschikbaar is voor deze leerling 
			set end of Leerlingen to Leerling
			set rowTeller to rowTeller + 1
		end if
	end repeat
end tell -- contacts

--- Pause
display alert "Leerlingen zijn opgehaald" message "Het script gaat verder met het vullen van de Numbers tabel" buttons {"Doorgaan"} giving up after 3

---
---	Maak Table aan in Numbers gevuld met leerlingen van die Lesdag	
---
set AantalRegels to count Leerlingen
set AantalKolommen to count item 1 of Leerlingen

tell application "Numbers"
	activate
	-- if not (exists document 1) then make new document
	make new document
	tell document 1
		tell active sheet
			delete first table
			
			--
			-- Maken Lescodes tabel
			--
			set LescodesRows to count of LesCodesTable
			set LescodesColumns to count of item 1 of LesCodesTable
			
			set referentieTable to ¬
				make new table with properties ¬
					{row count:LescodesRows, column count:LescodesColumns, name:"Lescodes"}
			tell referentieTable
				-- Fill Header Row
				repeat with myRow from 1 to LescodesRows
					repeat with q from 1 to LescodesColumns
						set the value of cell q of row myRow to item q of item myRow of LesCodesTable
					end repeat
				end repeat
			end tell
			
			--
			-- Maken Instellingen tabel
			--
			set InstellingenRows to count of InstellingenTable
			set InstellingenColumns to count of item 1 of InstellingenTable
			
			set referentieTable to ¬
				make new table with properties ¬
					{row count:InstellingenRows, column count:InstellingenColumns, name:"Instellingen"}
			tell referentieTable
				-- Fill Header Row
				repeat with myRow from 1 to InstellingenRows
					repeat with q from 1 to InstellingenColumns
						set the value of cell q of row myRow to item q of item myRow of InstellingenTable
					end repeat
				end repeat
			end tell
			
			
			--
			-- Maken Leerlingen tabel
			--			
			set thisTable to ¬
				make new table with properties ¬
					{row count:AantalRegels, column count:AantalKolommen, name:"Leerlingen administratie I/V - Petra Wielemaker"}
			tell thisTable
				-- Fill Header Row
				tell row 1
					repeat with q from 1 to (AantalKolommen)
						set the value of cell q to item q of Veldnamen
					end repeat
				end tell
				-- Fill the data rows
				repeat with i from 2 to AantalRegels
					tell row i
						set alignment to left
						set vertical alignment to center
						repeat with q from 1 to (AantalKolommen)
							set the value of cell q to item q of item i of Leerlingen
						end repeat
					end tell
				end repeat
				
				--
				-- Sorteren
				--		
				sort by column 1 -- Voornaam
				sort by column 2 -- Achternaam
				
			end tell
			
		end tell
	end tell
end tell

display alert "Klaar met het script" message "Ik start nu het programma 'Pages Data Merge' om van deze Lijst de facturen mee te maken."

tell application "Pages Data Merge"
	activate
end tell
