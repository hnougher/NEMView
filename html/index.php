<?php
if ($_SERVER['SERVER_NAME'] == 'nemview.hgn.id.au') {
  # Allow 5 minutes of caching
  header('Cache-Control: public, max-age=300, stale-while-revalidate=600');
  header('Expires: ' . date('r', time() + 300));
  header('X-LiteSpeed-Cache-Control: public, max-age=300, stale-while-revalidate=600');
  echo '<!-- Cached from ' .date('r', time()). ' -->';
} else {
  # No caching, for debugging
  header('Cache-Control: no-cache, no-store, must-revalidate');
  header('Expires: ' . date('r'));
  header('X-LiteSpeed-Cache-Control: no-cache, no-store');
  echo '<!-- Not cached -->';
}
?>

<h2>Maps (trial, incomplete)</h2>
<a href="/map">Map</a> (<?php
$regions = array('QLD','NSW','NSWN','NSWS','NSWW','VIC','SA','TAS');
foreach ($regions as $region)
  printf('<a href="/map/australia.svg#%s">%s</a> ', $region, $region);
?>)

<h2>Graphs</h2>

<h3>Dispatch Region Summaries</h3>

Full <a href="/graph/dispatch_nemsum/NEM">NEM</a> (<?php
$regions = array('NSW1', 'QLD1', 'SA1', 'TAS1', 'VIC1');
foreach ($regions as $region)
  printf('<a href="/graph/dispatch_regionsum/%s">%s</a> ', $region, $region);
?>)<br>

Simplified (<?php
foreach ($regions as $region)
  printf('<a href="/graph/dispatch_regionsum_simple/%s">%s</a> ', $region, $region);
?>)

<h3>Dispatch SCADA</h3>
<?php
foreach ($regions as $region) {
  printf('<a href="/graph/dispatch_scada/%s">%s</a> ( ', $region, $region);
  printf('<a href="/graph/dispatch_scada/%s/es2">Battery</a> ', $region);
  printf('<a href="/graph/dispatch_scada/%s/es2072">Coal+Gas</a> ', $region);
  printf('<a href="/graph/dispatch_scada/%s/es256">Hydro</a> ', $region);
  printf('<a href="/graph/dispatch_scada/%s/es4096">Solar</a> ', $region);
  printf('<a href="/graph/dispatch_scada/%s/es8192">Wind</a> ', $region);
  printf('<a href="/graph/dispatch_scada/%s/es1765">Other</a> )<br>', $region);
}
?>
<br>
/graph/dispatch_scada/&lt;region&gt;/es&lt;bitmask&gt;<br>
Notes for 'es' parameter. Bitwise addition of energy source types:<br>
<table style="border-collapse: collapse;" border="1">
  <tr><th>Bitwise Number</th><th>Source Type</th></tr>
  <tr><td>1</td><td>Bagasse</td></tr>
  <tr><td>2</td><td>Battery Storage</td></tr>
  <tr><td>4</td><td>Biomass and industrial materials</td></tr>
  <tr><td>8</td><td>Black coal</td></tr>
  <tr><td>16</td><td>Brown coal</td></tr>
  <tr><td>32</td><td>Coal mine waste gas</td></tr>
  <tr><td>64</td><td>Coal seam methane</td></tr>
  <tr><td>128</td><td>Diesel oil</td></tr>
  <tr><td>256</td><td>Hydro</td></tr>
  <tr><td>512</td><td>Kerosene - non aviation</td></tr>
  <tr><td>1024</td><td>Landfill biogas methane</td></tr>
  <tr><td>2048</td><td>Natural Gas (Pipeline)</td></tr>
  <tr><td>4096</td><td>Solar</td></tr>
  <tr><td>8192</td><td>Wind</td></tr>
</table>

<h3>Dispatch Constraint</h3>
This is a template only.<br>
Replace the last part of the URL with the constraint name.<br>
<a href="/graph/dispatch_constraint/N&gt;&gt;NIL_33_34">Dispatch Contraint N&gt;&gt;NIL_33_34</a>
