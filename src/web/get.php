<?php
 
function file_get_contents_utf8($fn) {
  $content = file_get_contents($fn);
  return mb_convert_encoding($content, 'UTF-8',
          mb_detect_encoding($content, 'UTF-8, ISO-8859-1', true));
}

	$link = $_GET['link'];
	$content = file_get_contents_utf8($link);

  //$referer = $_SERVER['SERVER_NAME'];
  //echo($referer );
  echo($content);
  
    
?>