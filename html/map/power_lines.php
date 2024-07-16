<?php
/**
 * Metadata for powerline paths.
 */
if (!defined('CALLED_BY_MAP')) {
	die();
}

/** Powerlines.
 * This array defines all the important information about powerlines.
 * 
 * Array Key	= Name of the powerline.
 *  Name		= Human readable name. Northern name first.
 *  State		= AU State.
 *  KVA			= The powerline rating.
 *  Points		= An array of $power_places keys that the line goes along.
 * 					A "!" in front indicates it doesn't stop there, just passes by.
 *  Notes		= Any futher notes that may help future updates.
 */
$power_lines = [
	// NSW Hunter
	/// South of Tamworth (Ex)
	/// South of Port Maquarie (Ex)
	/// East of Wollar (Ex)
	/// North of Hawkesbury River (Ex)
	["id"=>"83",		"name"=>"Muswellbrook to Liddell",				"state"=>"NSW", "kva"=>330, "points"=>["Muswellbrook", "Liddell"]],
	["id"=>"963(K)",	"name"=>"Hawks Nest to Tomago",					"state"=>"NSW", "kva"=>132, "points"=>["Hawks Nest", "!Tomago STS", "Tomago"]],
	["id"=>"963(T)",	"name"=>"Taree to Hawks Nest",					"state"=>"NSW", "kva"=>132, "points"=>["Taree", "Hawks Nest"]],
	["id"=>"96F",		"name"=>"Stroud to Tomago",						"state"=>"NSW", "kva"=>132, "points"=>["Stroud", "Tomago"]],
	["id"=>"96P",		"name"=>"Taree to Stroud",						"state"=>"NSW", "kva"=>132, "points"=>["Taree", "Stroud"]],
	["id"=>"9C8",		"name"=>"Stroud to Brandy Hill",				"state"=>"NSW", "kva"=>132, "points"=>["Stroud", "!Dungog", "Brandy Hill"]],

	// NSW Northern
	/// North of Tamworth (Inclusive)
	/// North of Port Maquarie (Inclusive)
	["id"=>"Unknown",	"name"=>"Kempsey to Port Macquarie",			"state"=>"NSW", "kva"=>132, "points"=>["Kempsey", "Port Macquarie"]],
#	["id"=>"0825",		"name"=>"Koolkhan to Koolkhan 2",				"state"=>"NSW", "kva"=> 66, "points"=>["Koolkhan", "Koolkhan 2"]],
	["id"=>"0893",		"name"=>"Lismore 132kV to Casino",				"state"=>"NSW", "kva"=> 66, "points"=>["Lismore 132kV", "Casino"]],
	["id"=>"0897",		"name"=>"Lismore 132kV to Alstonville",			"state"=>"NSW", "kva"=> 66, "points"=>["Lismore 132kV", "Alstonville"]],
	["id"=>"6501",		"name"=>"Casino to Koolkhan",					"state"=>"NSW", "kva"=> 66, "points"=>["Casino", "Koolkhan"]],
#	["id"=>"6504",		"name"=>"Grafton South to Five Mile",			"state"=>"NSW", "kva"=> 66, "points"=>["Grafton South", "Five Mile"]],
#	["id"=>"6505",		"name"=>"Koolkhan 2 to Grafton North",			"state"=>"NSW", "kva"=> 66, "points"=>["Koolkhan 2", "Grafton North"]],
#	["id"=>"6506",		"name"=>"Shannon Creek to Nymboida",			"state"=>"NSW", "kva"=> 66, "points"=>["Shannon Creek", "Nymboida"]],
#	["id"=>"6509",		"name"=>"Five Mile to Shannon Creek",			"state"=>"NSW", "kva"=> 66, "points"=>["Five Mile", "Shannon Creek"]],
#	["id"=>"6510",		"name"=>"Grafton North to Five Mile",			"state"=>"NSW", "kva"=> 66, "points"=>["Grafton North", "Five Mile"]],
#	["id"=>"6NY",		"name"=>"Glen Innes to Guyra",					"state"=>"NSW", "kva"=> 66, "points"=>["Glen Innes West", "Guyra"]],
	["id"=>"84",		"name"=>"Tamworth to Liddell",					"state"=>"NSW", "kva"=>330, "points"=>["Tamworth 330kV", "Liddell"]],
	["id"=>"85",		"name"=>"Armidale to Tamworth",					"state"=>"NSW", "kva"=>330, "points"=>["Armidale", "!Uralla", "Tamworth 330kV"]],
	["id"=>"8502",		"name"=>"Lismore East to Alstonville",			"state"=>"NSW", "kva"=> 66, "points"=>["Lismore East", "Alstonville"]],
	["id"=>"8503",		"name"=>"Ballina to Alstonville 1",				"state"=>"NSW", "kva"=> 66, "points"=>["Ballina", "Alstonville"]],
	["id"=>"8507",		"name"=>"Ballina to Alstonville 2",				"state"=>"NSW", "kva"=> 66, "points"=>["Ballina", "Alstonville"]],
	["id"=>"8510",		"name"=>"Lismore East to Lismore SW",			"state"=>"NSW", "kva"=> 66, "points"=>["Lismore East", "Lismore SW"]],
	["id"=>"8511",		"name"=>"Lismore 132kV to Lismore SW via S",	"state"=>"NSW", "kva"=> 66, "points"=>["Lismore 132kV", "Lismore South", "Lismore SW"]],
	["id"=>"8514",		"name"=>"Lismore 132kV to Lismore South 1",		"state"=>"NSW", "kva"=> 66, "points"=>["Lismore 132kV", "Lismore South"]],
	["id"=>"8515",		"name"=>"Lismore 132kV to Lismore South 2",		"state"=>"NSW", "kva"=> 66, "points"=>["Lismore 132kV", "Lismore South"]],
	["id"=>"8516",		"name"=>"Lismore 132kV to Lismore SW",			"state"=>"NSW", "kva"=> 66, "points"=>["Lismore 132kV", "Lismore SW"]],
	["id"=>"86",		"name"=>"Armidale to Uralla",					"state"=>"NSW", "kva"=>330, "points"=>["Armidale", "Uralla", "Tamworth 330kV"]],
	["id"=>"87",		"name"=>"Coffs Harbour to Armidale",			"state"=>"NSW", "kva"=>330, "points"=>["Coffs Harbour", "Armidale"], "note"=>"Tee to 89 Koolkhan"],
#	["id"=>"877",		"name"=>"Keepit Dam to Gunnedah",				"state"=>"NSW", "kva"=> 66, "points"=>["Keepit Dam", "Gunnedah"]],
	["id"=>"88",		"name"=>"Tamworth to Muswellbrook",				"state"=>"NSW", "kva"=>330, "points"=>["Tamworth 330kV", "Muswellbrook"]],
	["id"=>"887",		"name"=>"Glen Innes to GIW",					"state"=>"NSW", "kva"=>132, "points"=>["Glen Innes", "Glen Innes West"]],
	["id"=>"89",		"name"=>"Lismore 330kV to Coffs Harbour",		"state"=>"NSW", "kva"=>330, "points"=>["Lismore 330kV", "!Koolkhan", "Coffs Harbour"], "note"=>"Tee to 87 Armidale"],
	["id"=>"8C",		"name"=>"Dumaresq to Armidale C",				"state"=>"NSW", "kva"=>330, "points"=>["Dumaresq", "!Sapphire Wind Farm", "Armidale"]],
	["id"=>"8E",		"name"=>"Dumaresq to Armidale E",				"state"=>"NSW", "kva"=>330, "points"=>["Dumaresq", "Sapphire Wind Farm", "Armidale"]],
	["id"=>"964",		"name"=>"Port Macquarie to Taree",				"state"=>"NSW", "kva"=>132, "points"=>["Port Macquarie", "Taree"]],
	["id"=>"965",		"name"=>"Armidale to Kempsey",					"state"=>"NSW", "kva"=>132, "points"=>["Armidale", "Kempsey"]],
	["id"=>"966",		"name"=>"Koolkhan to Armidale",					"state"=>"NSW", "kva"=>132, "points"=>["Koolkhan", "Armidale"]],
	["id"=>"967",		"name"=>"Lismore 330kV to Koolkhan",			"state"=>"NSW", "kva"=>132, "points"=>["Lismore 330kV", "Koolkhan"]],
	["id"=>"968",		"name"=>"Narrabri to Tamworth",					"state"=>"NSW", "kva"=>132, "points"=>["Narrabri", "Tamworth 330kV"]],
	["id"=>"969",		"name"=>"Gunnedah to Tamworth",					"state"=>"NSW", "kva"=>132, "points"=>["Gunnedah", "Tamworth 330kV"]],
	["id"=>"96C",		"name"=>"Coffs Harbour to Armidale",			"state"=>"NSW", "kva"=>132, "points"=>["Coffs Harbour", "Armidale"]],
	["id"=>"96H",		"name"=>"Grafton East to Coffs Harbour",		"state"=>"NSW", "kva"=>132, "points"=>["Grafton East", "Coffs Harbour"]],
	["id"=>"96L",		"name"=>"Lismore 330kV to Tenterfield",			"state"=>"NSW", "kva"=>132, "points"=>["Lismore 330kV", "Casino", "Tenterfield"]],
	["id"=>"96M",		"name"=>"Moree to Narrabri",					"state"=>"NSW", "kva"=>132, "points"=>["Moree", "Narrabri"]],
	["id"=>"96N",		"name"=>"Inverell to Armidale",					"state"=>"NSW", "kva"=>132, "points"=>["Inverell", "Armidale"]],
	["id"=>"96R",		"name"=>"Glen Innes to Tenterfield",			"state"=>"NSW", "kva"=>132, "points"=>["Tenterfield", "Glen Innes"]],
	["id"=>"96T",		"name"=>"Glen Innes to Armidale",				"state"=>"NSW", "kva"=>132, "points"=>["Glen Innes", "Armidale"]],
	["id"=>"9G2",		"name"=>"Lennox Head to Ballina",				"state"=>"NSW", "kva"=>132, "points"=>["Lennox Head", "Ballina"]],
	["id"=>"9G3",		"name"=>"Suffolk Park to Lennox Head",			"state"=>"NSW", "kva"=>132, "points"=>["Suffolk Park", "Lennox Head"]],
	["id"=>"9G4",		"name"=>"Ewingsdale to Suffolk Park",			"state"=>"NSW", "kva"=>132, "points"=>["Ewingsdale", "Suffolk Park"]],
	["id"=>"9G5",		"name"=>"Mullumbimby to Ewingsdale",			"state"=>"NSW", "kva"=>132, "points"=>["Mullumbimby", "Ewingsdale"]],
	["id"=>"9U1",		"name"=>"Lismore 132kV to Lismore 330kV 1",		"state"=>"NSW", "kva"=>132, "points"=>["Lismore 132kV", "Lismore 330kV"]],
	["id"=>"9U2",		"name"=>"Moree to Inverell",					"state"=>"NSW", "kva"=>132, "points"=>["Moree", "Inverell"]],
	["id"=>"9U3",		"name"=>"Narrabri to Gunnedah",					"state"=>"NSW", "kva"=>132, "points"=>["Narrabri", "Gunnedah"]],
	["id"=>"9U4",		"name"=>"Inverell to WRWF",						"state"=>"NSW", "kva"=>132, "points"=>["Inverell", "White Rock Wind Farm"]],
	["id"=>"9U6",		"name"=>"Mullumbimby 1 to Lismore 132kV",		"state"=>"NSW", "kva"=>132, "points"=>["Mullumbimby", "Dunoon", "Lismore 132kV"]],
	["id"=>"9U7",		"name"=>"Mullumbimby 2 to Lismore 132kV",		"state"=>"NSW", "kva"=>132, "points"=>["Mullumbimby", "!Dunoon", "Lismore 132kV"]],
	["id"=>"9U8",		"name"=>"Lismore 132kV to Lismore 330kV 2",		"state"=>"NSW", "kva"=>132, "points"=>["Lismore 132kV", "Lismore 330kV"]],
	["id"=>"9U9",		"name"=>"Lismore 132kV to Lismore 330kV 3",		"state"=>"NSW", "kva"=>132, "points"=>["Lismore 132kV", "Lismore 330kV"]],
	["id"=>"9UG",		"name"=>"Glen Innes to WRWF",					"state"=>"NSW", "kva"=>132, "points"=>["Glen Innes West", "White Rock Wind Farm"]],
	["id"=>"9W0",		"name"=>"Koolkhan to Grafton East",				"state"=>"NSW", "kva"=>132, "points"=>["Koolkhan", "Grafton East"]],
	["id"=>"9W2",		"name"=>"Raleigh to Kempsey",					"state"=>"NSW", "kva"=>132, "points"=>["Raleigh", "!Nambucca Heads", "!Macksville", "Kempsey"]],
	["id"=>"9W3",		"name"=>"Coffs Harbour to Raleigh",				"state"=>"NSW", "kva"=>132, "points"=>["Coffs Harbour", "!Boambee South", "Raleigh"]],
	["id"=>"9W5",		"name"=>"Macksville to Kempsey",				"state"=>"NSW", "kva"=>132, "points"=>["Macksville", "Kempsey"]],
	["id"=>"9W6",		"name"=>"Nambucca Heads to Macksville",			"state"=>"NSW", "kva"=>132, "points"=>["Nambucca Heads", "Macksville"]],
	["id"=>"9W7",		"name"=>"Boambee South to Nambucca Heads",		"state"=>"NSW", "kva"=>132, "points"=>["Boambee South", "!Raleigh", "Nambucca Heads"]],
	["id"=>"9W8",		"name"=>"Coffs Harbour to Boambee South",		"state"=>"NSW", "kva"=>132, "points"=>["Coffs Harbour", "Boambee South"]],
	["id"=>"ACDLK",		"name"=>"Directlink AC",						"state"=>"NSW", "kva"=>110, "points"=>["Terranora", "Bungalora"], "note"=>"https://www.openstreetmap.org/relation/15852686"],
	["id"=>"HVDCDLK",	"name"=>"Directlink HVDC",						"state"=>"NSW", "kva"=>110, "points"=>["Bungalora","Mullumbimby"], "note"=>"https://www.openstreetmap.org/relation/15852686"],
#	["id"=>"TamTam1",	"name"=>"Tamworth 1",							"state"=>"NSW", "kva"=>132, "points"=>["Tamworth 132kV","Tamworth 330kV"]],
#	["id"=>"TamTam2",	"name"=>"Tamworth 2",							"state"=>"NSW", "kva"=>132, "points"=>["Tamworth 132kV","Tamworth 330kV"]],

	// QLD SE
	/// North of NSW/QLD Border (Inclusive)
	["id"=>"757",		"name"=>"Mudgeeraba to Terranora 1",			"state"=>"QLD", "kva"=>110, "points"=>["Mudgeeraba", "Terranora"]],
	["id"=>"758",		"name"=>"Mudgeeraba to Terranora 2",			"state"=>"QLD", "kva"=>110, "points"=>["Mudgeeraba", "Terranora"]],
	["id"=>"8L",		"name"=>"Bulli Creek to Dumaresq L",			"state"=>"QLD", "kva"=>330, "points"=>["Bulli Creek","Dumaresq"]],
	["id"=>"8M",		"name"=>"Bulli Creek to Dumaresq M",			"state"=>"QLD", "kva"=>330, "points"=>["Bulli Creek","Dumaresq"]],
];

#echo '<pre>';
#print_r($powerlines);