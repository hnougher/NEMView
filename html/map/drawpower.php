<?php
if (!defined('CALLED_BY_MAP')) {
	die();
}

// Import all the data to be used
require('power_places.php');
require('power_lines.php');


// Draw the places
/* foreach ($power_places as $key => $val) {
	printf("<circle class='place' cx='%F' cy='%F'/>\n", $val[1], $val[0]);
} */



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


// Calculate line load
foreach ($power_lines as $key => $line) {
	$power_lines[$key]['load'] = rand(-100, 100);
}

// Calculate line legs
$legs = [];
foreach ($power_lines as $line) {
	$points = $line['points'];
	for ($i = 0; $i < count($points) - 1; $i++) {
		$name1 = ($points[$i][0] == '!' ? substr($points[$i], 1) : $points[$i]);
		$name2 = ($points[$i+1][0] == '!' ? substr($points[$i+1], 1) : $points[$i+1]);
		$legs[$name1][$name2][] = $line;
	}
}

// Draw the lines
foreach ($legs as $name1 => $val1) {
	foreach ($val1 as $name2 => $lines) {
		$radian = getRadian($power_places[$name1], $power_places[$name2]) + M_PI/2;
		$offset = getOffset($radian, 0.015); # Powerline width = 0.01

		foreach ($lines as $lineIndex => $line) {
			$myOffsetIndex = ceil($lineIndex - (count($lines) / 2));
			$myOffset = multiplyOffset($offset, $myOffsetIndex);
			$place1 = applyOffset($power_places[$name1], $myOffset);
			$place2 = applyOffset($power_places[$name2], $myOffset);

			$path = sprintf("M %F,%F L %F,%F", $place1[1], $place1[0], $place2[1], $place2[0]);
			printf("<path class='powerline' lineid='%s' kva='%u' d='%s' offset='%s,%s,%s'/>\n", $line['id'], $line['kva'], $path, $myOffset[1], $myOffset[0], $radian);
			printf("<path class='powerline' lineid='%s' load='%+04d' d='%s'/>\n", $line['id'], $line['load'], $path);
		}
	}
}
