<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: X-Requested-With, Content-Type');
 
function file_get_contents_utf8($fn) {
    $content = file_get_contents($fn);
    $content = mb_convert_encoding(
        $content, 
        'UTF-8',
        mb_detect_encoding($content, 'UTF-8, ISO-8859-1', true)
    );
    return $content;
}

$content = file_get_contents_utf8(@$_GET['link']);
echo($content);

