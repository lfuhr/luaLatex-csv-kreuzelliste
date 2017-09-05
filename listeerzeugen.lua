-- pretty = require 'pl.pretty'

function round(num, numDecimalPlaces) -- nicht selbst implementiert
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local function bisher_angekreuzt( stud_blaetter, aktuelles_blatt )
	local zaehler = 0
	for vorangegangenes_blatt = 1, aktuelles_blatt - 1 do
		for _, evtl_kreuz in ipairs(stud_blaetter[vorangegangenes_blatt].aufgaben) do
			if (evtl_kreuz == 'X' or evtl_kreuz == 'V') then
				zaehler = zaehler + 1
			end
		end
	end
	return zaehler
end

function aufgaben_bisher( blattinfos, aktuelles_blatt )


	local zaehler = 0
	for vorangegangenes_blatt = 1, aktuelles_blatt - 1 do
		for _ in ipairs(blattinfos[vorangegangenes_blatt].aufgaben) do
			zaehler = zaehler + 1
		end
	end
	return zaehler
end

function print_table(kopfdaten, blattinfos, studenten, blatt_nummer)
	local s_table = ""

	--Beginn von Table
	s_table = s_table .."\\begin{tabularx}{\\linewidth}{|X|c|c"
	for i,v in ipairs(blattinfos[blatt_nummer].aufgaben) do
		s_table = s_table .. "|c"
	end
	s_table = s_table .."|} "

	--Head von Table: Anwesend, Student(Vorname, Name) Aufgaben...
	s_table = s_table .. "\\hline\n \\textbf{Student} & \\textbf{Bisher angekreuzt} & \\textbf{Anwesend}"
	for i,v in ipairs(blattinfos[blatt_nummer].aufgaben) do
		s_table = s_table .. " & \\textbf{" ..  v .. "}"
	end

	local aufgaben_bisher = aufgaben_bisher(blattinfos, blatt_nummer)

	--Main von Table
	for i,v in ipairs(studenten) do
		s_table = s_table .. " \\\\ \\hline\n"
		s_table = s_table .. studenten[i].Nachname .. ", " .. studenten[i].Vorname

		local bisher_angekreuzt = bisher_angekreuzt(studenten[i].blaetter, blatt_nummer)
		s_table = s_table .. " & " .. bisher_angekreuzt .. " bzw. " .. round(100 * bisher_angekreuzt / aufgaben_bisher, 0) .. "\\%"
		s_table = s_table .. " & $\\square$"
		for _ in ipairs(blattinfos[blatt_nummer].aufgaben) do
			s_table = s_table .. " & $\\square$"
		end
 	end

	--End von Table
	s_table = s_table .. "\\\\ \\hline \\end{tabularx}"

	return s_table
end

-- dofile("kreuzellesen.lua")
-- kopfdaten, blattinfos, studenten = lese_datei("mathe.csv")
-- print(print_table(kopfdaten, blattinfos, studenten, 3))