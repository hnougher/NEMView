<?php
if (!defined('CALLED_BY_MAP')) {
	die();
}

// Import all the data to be used
#require('power_places.php');
#require('power_lines.php');

// Define some functions
function getRadian($p1, $p2) {
	return atan2($p2[0] - $p1[0], $p2[1] - $p1[1]);
}
function applyOffset($origin, $offset) {
	$x = $origin[1] + $offset[1];
	$y = $origin[0] + $offset[0];
	return [$y, $x];
}
function getOffset($radian, $distance) {
	$x = $distance * cos($radian);
	$y = $distance * sin($radian);
	return [$y, $x];
}
function multiplyOffset($offset, $multplier) {
	return [ $offset[0]*$multplier, $offset[1]*$multplier ];
}
function getOffsetApplied($radian, $distance, $origin) {
	return applyOffset($origin, getOffset($radian, $distance));
}
function getKMBetweenCoords($lat1, $lon1, $lat2, $lon2) {
	$R = 6371; // Radius of the earth in km
	$dLat = deg2rad($lat2 - $lat1);
	$dLon = deg2rad($lon2 - $lon1);
	$a = sin($dLat/2) * sin($dLat/2) + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLon/2) * sin($dLon/2);
	$c = 2 * atan2(sqrt($a), sqrt(1-$a));
	$d = $R * $c; // Distance in km
	return $d;
}


// Connect to the database
try {
	$pg = new PDO('pgsql:host=10.240.0.165;port=5432;dbname=nem', 'nem_worker', 'hgknIOGNUyiutbui7^%g', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_TIMEOUT => 5]);
} catch (PDOException $e) {
	die('Connection failed: ' . $e->getMessage());
}


echo '<text x="148" y="28.2" style="fill:black; font-size: 0.1px; white-space: break-spaces" transform="scale(1 -1)">';

// Get power data from database
$result = $pg->query('SELECT name, coordinate[0] lon, coordinate[1] lat FROM hn_places');
$result = $result->fetchAll(PDO::FETCH_ASSOC);
$power_places = [];
foreach ($result as $row) {
	$power_places[$row['name']] = [$row['lat'],$row['lon']];
}


// Get power line legs from database
$sql = <<<SQL
SELECT line_id, "limit", actual, rating, rating_type, name, kva, is_major_line, is_outage
	, to_json(place_names) place_names, to_json(place_bypassed) place_bypassed
FROM hn_lines l
LEFT JOIN (
	SELECT line_id, rating_type, MIN("limit") * (CASE WHEN AVG(actual) < 0 THEN -1 ELSE 1 END) "limit",
		AVG(actual) actual, MIN(rating) rating, bool_or(is_outage) is_outage
	FROM ( 
		SELECT l.line_id, c.segment_id, c.constraint_id, c.reversed, c.priority, c.multiplier, d.rhs, d.lhs, c.is_outage
			, (rhs * multiplier) AS "limit"
			, (lhs * multiplier) * (CASE reversed WHEN true THEN -1 ELSE 1 END) AS actual
			, a.rating, a.rating_type
		FROM hn_lines l
			JOIN hn_constraint_line_link c USING(line_id)
			JOIN dispatch_constraint d ON constraintid = constraint_id
			LEFT JOIN LATERAL (
				SELECT equipment_id, string_agg(rating_type,',') rating_type, MIN(rating) rating
				FROM ter_daily_lim_altlim JOIN hn_alternate_values(d.settlementdate) USING(alternate_value_id)
				WHERE rating_level = 'NORM' AND rating >= 0
				GROUP BY 1
				) a ON line_id = equipment_id
		WHERE priority < 50
			AND d.settlementdate = (SELECT MAX(settlementdate) FROM dispatch_constraint)
	) z
	GROUP BY 1,2
) z USING(line_id)
WHERE is_major_line = true OR z.actual IS NOT NULL
ORDER BY 1
SQL;
$result = $pg->query($sql);
$power_lines = [];
foreach ($result as $row) {
	$line = [
		'id' => $row['line_id'],
		'place_names' => json_decode($row['place_names']),
		'place_bypassed' => json_decode($row['place_bypassed']),
		'kva' => $row['kva'],
		'limit' => $row['limit'],
		'actual' => $row['actual'],
		'is_outage' => $row['is_outage'],
	];

	// If there is no rating, extrapolate it from the distance between the first and last place
	$rating = $row['rating'];
	if ($rating == null && $line['actual'] != null && is_array($line['place_names']) && count($line['place_names']) >= 2) {
		$places = $line['place_names'];
		$start = $power_places[$places[0]];
		$end = $power_places[$places[count($places)-1]];
		$distance = getKMBetweenCoords($start[0], $start[1], $end[0], $end[1]);
		$rating = ($line['kva'] * $line['kva']) / ($distance * 0.726);
		#printf("ID:%s, KVA:%s, Distance:%s, Rating:%s, Limit:%s\n", $line['id'], $line['kva'], $distance, $rating, $line['limit']);
	}

	// After fixing missing data, calculate the load and reserve
	if (strpos($row['rating_type'],'DYNAMIC') !== false && !empty($line['limit']) && $rating <= $line['limit']) {
		$line['rating'] = $line['limit'];
		$line['load'] = $line['actual'] / $line['limit'] * 100;
		$line['reserve'] = null;
	} else {
		$line['rating'] = $rating;
		$line['load'] = empty($rating) ? 0 : $line['actual'] / $rating * 100;
		$line['reserve'] = empty($rating) || $line['limit'] == null ? 0 : max(-1,min(1,$line['limit'] / $rating)) * 100;		
	}
	$power_lines[] = $line;
}
#print_r($power_lines);

#print_r($power_legs);
echo '</text>';



// Calculate line legs
$legs = [];
$textOut = '';
foreach ($power_lines as $line) {
	if (!is_array($line['place_names'])) continue;
	$points = $line['place_names'];
	for ($i = 0; $i < count($points) - 1; $i++) {
		$name1 = ($points[$i][0] == '!' ? substr($points[$i], 1) : $points[$i]);
		$name2 = ($points[$i+1][0] == '!' ? substr($points[$i+1], 1) : $points[$i+1]);
		$reversed = false;
		if ($power_places[$name1][0] < $power_places[$name2][0]) {
			// Wrong order, swap
			$tmp = $name1;
			$name1 = $name2;
			$name2 = $tmp;
			$reversed = true;
		}
		$legs[$name1][$name2][] = [$line, $reversed];
	}
}

// Draw the lines
foreach ($legs as $name1 => $val1) {
	foreach ($val1 as $name2 => $lines) {
		$radian = getRadian($power_places[$name1], $power_places[$name2]) + M_PI/2;
		$offset = getOffset($radian, 0.015); # Powerline width = 0.01

		foreach ($lines as $lineIndex => $d) {
			$line = $d[0];
			$reversed = $d[1];
			$myOffsetIndex = ceil($lineIndex - (count($lines) / 2));
			$myOffset = multiplyOffset($offset, $myOffsetIndex);

			$place1 = applyOffset($power_places[$reversed ? $name2 : $name1], $myOffset);
			$place2 = applyOffset($power_places[$reversed ? $name1 : $name2], $myOffset);
			#$place1 = applyOffset($power_places[$name1], $myOffset);
			#$place2 = applyOffset($power_places[$name2], $myOffset);

			$path = sprintf("M %F,%F L %F,%F", $place1[1], $place1[0], $place2[1], $place2[0]);
			//printf("<path class='powerline' lineid='%s' kva='%u' d='%s' offset='%s,%s,%s'/>\n", $line['id'], $line['kva'], $path, $myOffset[1], $myOffset[0], $radian);
			printf("<path class='powerline' lineid='%s' kva='%u' d='%s'/>\n", $line['id'], $line['kva'], $path);
			if ($line['is_outage']) {
				printf("<path class='powerline outage' lineid='%s' d='%s'/>\n", $line['id'], $path);
			} else {
				if ($line['reserve'] != null)
					printf("<path class='powerline' lineid='%s' reserve='%+04d' d='%s'/>\n", $line['id'], $line['reserve'] < 0 ? ceil($line['reserve']) : floor($line['reserve']), $path);
				if ($line['load'] != null)
					printf("<path class='powerline' lineid='%s' load='%+04d' d='%s'/>\n", $line['id'], $line['load'] < 0 ? floor($line['load']) : ceil($line['load']), $path);
			}

			// Label in the centre of the line with the line id
			$textOut .= sprintf("<text class='powerline' lineid='%s' x='%F' y='%F' transform='scale(1 -1)'>%s</text>\n", $line['id'], ($place1[1] + $place2[1]) / 2, -($place1[0] + $place2[0]) / 2, $line['id']);
		}
	}
}

echo $textOut;
