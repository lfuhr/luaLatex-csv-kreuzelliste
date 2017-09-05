KENNZ_BEGINN = "#"
KENNZ_BLATT = "$"

-- Generische Funktionen
function string.starts(String,Start) -- nicht selbst implementiert
   return string.sub(String,1,string.len(Start))==Start
end

function map(func, array) -- nicht selbst implementiert
	local new_array = {}
	for i,v in ipairs(array) do
	  new_array[i] = func(v)
	end
	return new_array
end

function trim(s) -- nicht selbst implementiert
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Reines Lua kennt kein Explode. Quickfix, damit es trotzdem geht.
if not string.explode then
	function string.explode(string, _)
		local words = {}
		for w in (string .. ";"):gmatch("([^;]*);") do table.insert(words, w) end
	    return words
	end
end


-- Spezifische funktionen
function zellen( zeile )
	return map(trim, string.explode(zeile, ";"))
end

function lese_datei(datei_name)
	local iterator, erstezeile, kopfdaten = lese_datei_kopf(datei_name);
	local iterator, blattinfos, studenten_felder = lese_datei_aufgaben(erstezeile, iterator);
	local studenten = lese_datei_studenten(iterator, blattinfos, studenten_felder)
	return kopfdaten, blattinfos, studenten
end

function lese_datei_kopf(datei_name)
	local iterator = io.lines(datei_name)
	local kopfdaten={}

	for line in iterator do
		line = zellen(line)
		if string.starts(line[1], KENNZ_BEGINN) then
			line[1] = string.sub(line[1], 2)
			return iterator, line, kopfdaten
		else
			kopfdaten[line[1]]=line[2]
		end
	end
	error("Es wurde keine Zeile die mit \"" .. KENNZ_BEGINN .. "\" beginnt im Dokument gefunden.")
end

function lese_datei_aufgaben(zeile_blatt, iterator)

	local zeile_aufg = zellen(iterator())
	local blattinfos = {}
	local studenten = {}

	-- Sammle Aufgabenblätter in Blattinfox
	local studenten_felder = {}
	local letztes_blatt = {aufgaben=studenten_felder}
	for index, element in ipairs(zeile_blatt) do
		if string.starts(element, KENNZ_BLATT) then
			letztes_blatt = { name=string.sub(element, 2), index=index, aufgaben={} }
			table.insert(blattinfos, letztes_blatt)
		else
			table.insert(letztes_blatt.aufgaben, element)
		end
	end

	return iterator, blattinfos, studenten_felder
end

function lese_datei_studenten( iterator, blattinfos, studenten_felder )
	local studenten={}
	--Student={Vorname, Nachname, Matrikelnummer, blaetter={Blatt}}
	--Blatt={anwesend, aufgabe={Aufgaben}}
	--Aufgaben={aufgaben={1,2,3}}
	for line in iterator do
		local student={}
		line = zellen(line)

		student[studenten_felder[1]]=line[1]
		student[studenten_felder[2]]=line[2]
		student[studenten_felder[3]]=line[3]

		local blaetter={}
		for index, element in ipairs(blattinfos) do

			local blatt={}
			blatt.anwesend=line[element.index]

			aufgaben={}
			for i,v in ipairs(element.aufgaben) do
				table.insert(aufgaben,line[element.index+i])
			end
			blatt.aufgaben=aufgaben
			table.insert(blaetter, blatt)
		end
		student.blaetter=blaetter
		table.insert(studenten, student)
	end

	return studenten
end

-- Debugging Bereich.

--kopfdaten, blattinfos, studenten = lese_datei("mathe.csv")
--print(studenten[1].Vorname)
--print(studenten[2].Nachname)
--print(studenten[1].Matrikelnummer)
--print(studenten[1].blaetter[1].aufgaben[2])
--print("Semester", kopfdaten.Semester)
--print("Blatt2", blattinfos[1].aufgaben[2])
--print("Blatt2", blattinfos[1].index)
--print("Entfernt auch Leerzeichen", zellen("Hallo ; Welt")[1])


