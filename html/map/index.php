<?php
header('Cache-Control: no-cache, no-store, must-revalidate');
header('X-LiteSpeed-Cache-Control: no-cache, no-store');
#header('Cache-Control: public, max-age=86400, stale-while-revalidate=86400');
header('Expires: ' . date('r'));
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
    <object data="australia.svg#NSWN">
</body>
</html> 