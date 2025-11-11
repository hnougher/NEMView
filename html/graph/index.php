<?php
/**
 * This is the primary enry point for all graph requests.
 * It will have the URL rewrite rules send the path below /graph/ to parameter $_SERVER['REDIRECT_URL'] as the path.
 * 
 * The path is made up of the following parts:
 * 1. The content template to use. Possible values are:
 *   a. dispatch_constraint.
 *   b. dispatch_regionsum.
 * 2. The primary identifier for the template.
 * 3. The further parameters if the template needs them.
 */

$startProcessing = -hrtime(true);
$sqlProcessing = 0;
date_default_timezone_set('Etc/GMT-10'); # Timezone is UTC+10 all year

// Calculate the next time a refresh should happen, randomness is added to prevent all clients refreshing at the same time
$secToNext = 300 - (time() % 300) + 90;
if ($secToNext > 300) $secToNext -= 300;
header('Refresh: ' . $secToNext + rand(0,30));

// Set the cache headers
if ($_SERVER['SERVER_NAME'] == 'nemview.hgn.id.au') {
  header('Expires: ' . date('r', time() + $secToNext-5));
  header(            'Cache-Control: public, max-age='.max(0,$secToNext-5).', stale-while-revalidate=300');
  header('X-LiteSpeed-Cache-Control: public, max-age='.max(0,$secToNext-5).', stale-while-revalidate=300');
  #echo '<!-- Cached from ' .date('r', time()). ' -->';
} else {
  # No caching, for debugging
  header('Expires: ' . date('r'));
  header('Cache-Control: no-cache, no-store, must-revalidate');
  header('X-LiteSpeed-Cache-Control: no-cache, no-store');
  #header('X-LiteSpeed-Cache-Control: public, max-age=30');
  #echo '<!-- Not cached -->';
}


// Import the SVGGraph classes
require '../svggraph/autoloader.php';

// Definitions array
$graphHeight = 562;
$graphWidth = 900;
$definitions = [
  'global_settings' => [
    'auto_fit' => true,
    'axis_text_angle_h' => -90,
    'datetime_keys' => true,
    'datetime_key_format' => 'U',
    'datetime_text_format' => [
      'second' => 'H:i:s',
      'minute' => 'H:i',
      'hour' => 'H:i',
      'day' => 'M d',
      'month' => 'Y-m',
      'year' => 'Y'
    ],
    'graph_title' => 'Undefined Graph Title',
    'label_h' => 'Time',
    'label_v' => 'MW',
    'legend_autohide' => true,
    'legend_draggable' => true,
    'legend_font_size' => 8,
    'legend_padding_y' => 0,
    'legend_position' => 'left',
    'legend_spacing' => -7,
    'legend_unique_fields' => true,
    'marker_size' => 0,
    'marker_type' => 'circle',
    'structured_data' => true,
  ],
  'types' => [
    'MultiLineGraph' => [
      'settings' => []
    ]
  ],
  'templates' => [

    'dispatch_constraint' => [
      'type' => 'MultiLineGraph',
      'identifier_sql' => "SELECT * FROM public.hn_constraints WHERE constraint_id = :primary LIMIT 1",
      'identifier_params' => [],
      'data_sql' => "SELECT floor(extract(epoch from settlementdate)) settlementdate
        , lhs
        , rhs
        FROM public.dispatch_constraint
        WHERE constraintid = :primary AND settlementdate >= NOW() - CAST(:interval AS Interval)
        ORDER BY settlementdate",
      'data_params' => [
        'interval' => ['pattern' => '/^(?:([1-7])(days?)|([12]?[0-9])(hours?))$/', 'replacement' => '$1$3 $2$4', 'default' => '1 day'],
      ],
      'string_params' => [],
      'settings' => [
        'graph_title' => '{primary} Dispatch Constraint',
        'legend_entries' => ['LHS', 'RHS'],
        'structure' => [
          'key' => 'settlementdate',
          'value' => ['lhs', 'rhs']
        ]
      ]
    ],

    'dispatch_regionsum' => [
      'type' => 'MultiLineGraph',
      'identifier_sql' => "SELECT regionid FROM public.dispatch_regionsum WHERE regionid = :primary LIMIT 1",
      'identifier_params' => [],
      'data_sql' => "SELECT *
        FROM public.graph_dispatch_regionsum
        WHERE regionid = :primary
        AND settlementdate       >= DATE_TRUNC('hour', NOW() - CAST(:interval AS Interval) + INTERVAL '5 min')
        AND settlementdate_inner >= DATE_TRUNC('hour', NOW() - CAST(:interval AS Interval) + INTERVAL '5 min')
        ORDER BY settlementdate",
      'data_params' => [
        'interval' => ['pattern' => '/^(?:([1-7])(days?)|([12]?[0-9])(hours?))$/', 'replacement' => '$1$3 $2$4', 'default' => '2 days'],
      ],
      'string_params' => [],
      'data_y_max' => ['fields' => ['dispatchablegeneration','demand_and_nonschedgen'], 'multiplier' => 1.0],
      'settings' => [
        'colours' => ['red','red', 'blue', 'blue', 'orange', 'orange',  'yellowgreen', 'olive', 'green', 'yellowgreen', 'olive', 'mediumaquamarine', 'brown', 'magenta', 'purple', 'purple', 'purple', 'purple'],
        'line_dash' => ['1',  '0',    '1',    '0',      '1',      '0',            '1',     '1',     '0',           '0',     '0',                '0',     '0',       '0',      '1',      '1',      '0',      '0'],
        'line_stroke_width' => [1,2,    1,      2,        1,        2,              1,       1,       2,             1,       1,                  1,       2,         2,        1,        1,        2,        2],
        'graph_title' => '{primary} Dispatch Regional Summary',
        'label' => [[$graphWidth/2, 44, "Dispatch values are what was supposed to happen in the next 5 minutes, not what happened in hindsight\nCoal, Gas, Hydro is SCADA data and doesn't consider powerline losses, hence a 0.9 multiplier, hence an estimate (see TAS1)", 'font_size' => 8]],
        'legend_entries' => [
          'Market Demand', 'Operational Demand', 'Reserve Generation', 'Dispatched Generation', 'Available Load w/o BDU', 'Dispatched Load w/o BDU',
          null,null, 'Solar+Wind+(Hydro*0.9)',null,null,null, 'Coal + Gas(Pipeline) *0.9', 'WDR Dispatched', 'BDU Min/Max', 'BDU Min/Max', 'BDU Gen/Load',null
        ],
        'structure' => [
          'key' => 'settlementdate',
          'value' => [
            'totaldemand', 'demand_and_nonschedgen', 'remaininggeneration', 'dispatchablegeneration', 'availableload', 'dispatchableload',
            'ss_solar_uigf', 'ss_wind_uigf', 'renwable_cleared', 'ss_solar_clearedmw', 'ss_wind_clearedmw', 'hydro',
            'coal_gas', 'wdr_dispatched', 'bdu_max_load', 'bdu_max_gen', 'bdu_clearedmw_gen', 'bdu_clearedmw_load'
          ]
        ]
      ]
    ],

    'dispatch_nemsum' => [
      'copy' => 'dispatch_regionsum',
      'identifier_sql' => "SELECT 1 WHERE :primary = 'NEM'",
      'data_sql' => "SELECT * FROM public.graph_dispatch_nemsum
        WHERE :primary = 'NEM'
        AND settlementdate       >= DATE_TRUNC('hour', NOW() - CAST(:interval AS Interval) + INTERVAL '5 min')
        AND settlementdate_inner >= DATE_TRUNC('hour', NOW() - CAST(:interval AS Interval) + INTERVAL '5 min')
        ORDER BY settlementdate",
      'settings' => [
        'graph_title' => 'NEM Dispatch Summary',
      ]
    ],

    'dispatch_scada' => [
      'type' => 'MultiLineGraph',
      'identifier_sql' => "SELECT DISTINCT duid
        FROM dispatch_scada
        WHERE regionid = :primary
          AND ((:es & 1     >0 AND energy_source = 'Bagasse')
            OR (:es & 2     >0 AND energy_source = 'Battery Storage')
            OR (:es & 4     >0 AND energy_source = 'Biomass and industrial materials')
            OR (:es & 8     >0 AND energy_source = 'Black coal')
            OR (:es & 16    >0 AND energy_source = 'Brown coal')
            OR (:es & 32    >0 AND energy_source = 'Coal mine waste gas')
            OR (:es & 64    >0 AND energy_source = 'Coal seam methane')
            OR (:es & 128   >0 AND energy_source = 'Diesel oil')
            OR (:es & 256   >0 AND energy_source = 'Hydro')
            OR (:es & 512   >0 AND energy_source = 'Kerosene - non aviation')
            OR (:es & 1024  >0 AND energy_source = 'Landfill biogas methane')
            OR (:es & 2048  >0 AND energy_source = 'Natural Gas (Pipeline)')
            OR (:es & 4096  >0 AND energy_source = 'Solar')
            OR (:es & 8192  >0 AND energy_source = 'Wind')
            )
          AND scadavalue > 0
          AND settlementdate >= DATE_TRUNC('hour', NOW() - CAST(:interval AS Interval) + INTERVAL '5 min')
        ORDER BY duid",
      'identifier_params' => [
        'interval' => ['pattern' => '/^(?:([1-7])(days?)|([12]?[0-9])(hours?))$/', 'replacement' => '$1$3 $2$4', 'default' => '1 days'],
        'es' => ['pattern' => '/^es([0-9]{1,5})$/', 'replacement' => '$1', 'default' => '16383']
      ],
      'data_sql' => "SELECT settlementdate #LOOP0#
        FROM dispatch_scada
        WHERE regionid = :primary
          AND settlementdate >= DATE_TRUNC('hour', NOW() - CAST(:interval AS Interval) + INTERVAL '5 min')
        GROUP BY settlementdate
        ORDER BY settlementdate",
      'data_params' => [
        'interval' => ['pattern' => '/^(?:([1-7])(days?)|([12]?[0-9])(hours?))$/', 'replacement' => '$1$3 $2$4', 'default' => '1 days'],
      ],
      'data_sql_loops' => [",sum(scadavalue) FILTER (WHERE duid = '#duid#') AS \"#duid#\""],
      'string_params' => [],
      'settings' => [
        'graph_title' => '{primary} Dispatch SCADA',
        'label' => [[$graphWidth/2, 44, "This will not show generators that are 0 over the visible period.", 'font_size' => 8]],
        'legend_entries_loop' => '#duid#',
        'legend_columns' => 2,
        'legend_spacing' => -12,
        'line_stroke_width' => [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        'line_dash' => [null,null,null,null,null,null,null,null,null,null,2,2,2,2,2,2,2,2,2,2,null,null,null,null,null,null,null,null,null,null,1,1,1,1,1,1,1,1,1,1]
      ]
    ],
  ]
];

// Connect to the database
try {
  $sqlStart = -hrtime(true);
	$pg = new PDO('pgsql:host=10.240.0.165;port=5432;dbname=nem', 'nem_worker', 'hgknIOGNUyiutbui7^%g', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_TIMEOUT => 5]);
  $sqlProcessing += $sqlStart + hrtime(true);
} catch (PDOException $e) {
	die('Connection failed: ' . $e->getMessage());
}

// Get the path and split it into its parts
$path = empty($_SERVER['REDIRECT_URL']) ? $_SERVER['REQUEST_URI'] : $_SERVER['REDIRECT_URL'];
$path = explode('/', substr($path, 7));
#print_r($path);

// Check the path has enough parts
if (count($path) < 2) {
  http_response_code(410);
  die('Error 410: Not enough path parts.');
}

// Check path against $definitions
// 0 against the template keys
if (!isset($definitions['templates'][$path[0]])) {
  http_response_code(404);
  die('Error 404: Unknown content template.');
}
$template = $definitions['templates'][$path[0]];
// If the template has a copy key, copy the settings from the template with that key
if (isset($template['copy'])) {
  $template = array_merge($definitions['templates'][$template['copy']], $template);
  $template['settings'] = array_merge($definitions['templates'][$template['copy']]['settings'], $template['settings']);
}
// 2 is checked using the identifier_sql
if (!isset($template['identifier_sql'])) {
  http_response_code(404);
  die('Error 404: No identifier_sql defined.');
}

// All remaining path parts are parameters in any order
// Create 2 results arrays, one for the identifier and one for the data, both with a 'primary' key for the primary identifier
// Each path part needs to match one of the patterns, and will be replaced with the string result from replacement, otherwise the default string will be used
// If a path part doesn't match any pattern in either set, an http 400 error will be returned
$identifier_params = ['primary' => $path[1]];
$data_params = ['primary' => $path[1]];
$string_params = ['primary' => $path[1]];
for ($i = 2; $i < count($path); $i++) {
  $found = false;
  foreach ($template['identifier_params'] as $key => $param) {
    if (preg_match($param['pattern'], $path[$i])) {
      $identifier_params[$key] = preg_replace($param['pattern'], $param['replacement'], $path[$i]);
      $found = true;
      break;
    }
  }
  foreach ($template['data_params'] as $key => $param) {
    if (preg_match($param['pattern'], $path[$i])) {
      $data_params[$key] = preg_replace($param['pattern'], $param['replacement'], $path[$i]);
      $found = true;
      break;
    }
  }
  foreach ($template['string_params'] as $key => $param) {
    if ($path[$i] == $key) {
      $string_params[$key] = $param;
      $found = true;
      break;
    }
  }
  if (!$found) {
    http_response_code(400);
    die('Error 400: Invalid path part ' . $path[$i]);
  }
}

// Set default values for missing parameters
foreach ($template['identifier_params'] as $key => $param) {
  if (!isset($identifier_params[$key])) {
    $identifier_params[$key] = $param['default'];
  }
}
foreach ($template['data_params'] as $key => $param) {
  if (!isset($data_params[$key])) {
    $data_params[$key] = $param['default'];
  }
}
foreach ($template['string_params'] as $key => $param) {
  if (!isset($string_params[$key])) {
    $string_params[$key] = $param;
  }
}
#print_r($identifier_params);
#print_r($data_params);
#print_r($string_params);

/// Output the graph
// Check the identifier exists
$sqlStart = -hrtime(true);
$stmt = $pg->prepare($template['identifier_sql']);
$stmt->execute($identifier_params);
$identifier = $stmt->fetchAll(PDO::FETCH_ASSOC);
$sqlProcessing += $sqlStart + hrtime(true);
if (!$identifier) {
  http_response_code(404);
  die('Error 404: Identifier not found.');
}

// Merge the settings
$graphType = $template['type'];
$settings = array_merge($definitions['global_settings'], $definitions['types'][$graphType]['settings'], $template['settings']);

// Replace the string parameters
foreach ($string_params as $key => $value) {
  $settings['graph_title'] = str_replace('{' . $key . '}', $value, $settings['graph_title']);
}

/**
 * Processes SQL loop fragments defined in `data_sql_loops`:
 * 1. Check if `data_sql_loops` is defined in the settings.
 * 2. For each loop fragment:
 *    a. Iterate through the rows of the identifier result set.
 *    b. Replace all placeholders (e.g., #<colname>#) in the loop string with the corresponding values from the row.
 *    c. Append the processed string for each row to a cumulative string.
 *    d. Replace the corresponding #LOOP<key># placeholder in `data_sql` with the cumulative string.
 * 3. This ensures that each loop is processed independently and the final SQL is updated incrementally.
 */
if (isset($template['data_sql_loops'])) {
  foreach ($template['data_sql_loops'] as $key => $loop) {
    $str = '';
    foreach ($identifier as $row) {
      $rowStr = $loop;
      foreach ($row as $field => $value) {
        $rowStr = str_replace('#' . $field . '#', $value, $rowStr);
      }
      $str .= $rowStr;
    }
    $template['data_sql'] = str_replace('#LOOP' . sprintf('%01d', $key) . '#', $str, $template['data_sql']);
  }
}

// Process the legend entries loop if it is defined, resulting in an array of strings
if (isset($settings['legend_entries_loop'])) {
  $legend_entries = [];
  foreach ($identifier as $row) {
    $rowStr = $settings['legend_entries_loop'];
    foreach ($row as $field => $value) {
      $rowStr = str_replace('#' . $field . '#', $value, $rowStr);
    }
    $legend_entries[] = $rowStr;
  }
  $settings['legend_entries'] = $legend_entries;
}

// Load the graph data from the database
$sqlStart = -hrtime(true);
$stmt = $pg->prepare($template['data_sql']);
$stmt->execute($data_params);
$data = $stmt->fetchAll(PDO::FETCH_ASSOC);
$sqlProcessing += $sqlStart + hrtime(true);
#print_r($data);

// Check the data is not empty
if (count($data) == 0) {
  http_response_code(404);
  die('Error 404: Empty dataset.');
}

// Is there axis limits in settings?
if (isset($template['data_y_max'])) {
  $data_y_max = $template['data_y_max'];
  $max = PHP_INT_MIN;
  // Is it a field maximum?
  if (isset($data_y_max['fields']))
    foreach ($data as $row)
      foreach ($data_y_max['fields'] as $field)
        $max = max($max, $row[$field]);
  if (isset($data_y_max['multiplier']))
    $max = $max * $data_y_max['multiplier'];
  $settings['axis_max_v'] = $max;
}

// Set up the graph
$graph = new Goat1000\SVGGraph\SVGGraph($graphWidth, $graphHeight, $settings);
$graph->values($data);
if (isset($settings['colours']))
  $graph->colours($settings['colours']);
$out = $graph->fetch($graphType, true, false);

// Output the graph and processing time
header('Content-Type: image/svg+xml');
$sqlTime = round($sqlProcessing / 1e+6);
$processingTime = round(($startProcessing + hrtime(true) - $sqlProcessing) / 1e+6);
echo substr($out, 0, -7);
printf('<title>%s</title>', $settings['graph_title']);
printf('<text x="%u" y="%u" font-size="7" fill="#888">Created by NEMView (https://nemview.hgn.id.au/) using AEMO public data and Goat1000/SVGGraph on a AU$5/month PHP+PG+OLS server.</text>', 5, $graphHeight-5);
printf('<text x="%u" y="%u" font-size="7" fill="#888">PHP:%ums PG:%ums Total:%ums Cached until:%s</text>', $graphWidth-200, $graphHeight-5, $processingTime, $sqlTime, $processingTime+$sqlTime, date('H:i:s', time()+$secToNext-5));
# JS to reload page based on UTC time in milliseconds for next refresh, in case of cache or tab is inactive
$utcNextRefreshMillis = (time() + $secToNext + 15) * 1000;
printf('<script type="text/ecmascript"><![CDATA[
  const delayMillis = Math.max(10000, %u - Date.now());
  setTimeout(function(){location.reload();}, delayMillis);
]]></script>', $utcNextRefreshMillis);
echo '</svg>';
