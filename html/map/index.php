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
<!DOCTYPE html>
<html>
<head>
  <style>
    html, body {
      margin: 0;
      padding: 0;
    }
    img, object {
      position: fixed;
      width: 100%;
      height: 100%;
    }
  </style>
</head>
<body>
 <object data="australia.svg#NSW">
</body>
</html> 