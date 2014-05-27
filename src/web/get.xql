xquery version "3.0";

declare namespace xhtml ="http://www.w3.org/1999/xhtml" ;

let $data:= doc("/db/apps/smc-browser/data/smc_stats_detail.html")

let $type := request:get-parameter('type','profile')
let $key := request:get-parameter('key','')

return $data//xhtml:div[data(@id)=$type||'-'||$key]