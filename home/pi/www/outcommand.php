<?php

$camUser = "hass";
$camPass = "we89FEW3ji";

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
	if ($_GET["entity"] == "switch.larm_motion_foscam_black") {
		$switchStateOn = file_get_contents('php://input') == "ON";
		if ($switchStateOn) {
			$motionArg = "motion_armed=1";
			$httpAlarmArg = "http=1";
			$urlArg = "http_url=http%3A%2F%2F192.168.9.212%3A8686%2Fcommand.php%3Fsensor%3Dcam.foscam.black.motion%26state%3Don";
			//$result = http_get("http://".$camUser.":".$camPass."192.168.9.208/set_alarm.cgi?".$motionArg."&".$httpAlarmArg."&".$urlArg);
			$result = sendGet("http://192.168.9.208/set_alarm.cgi?".$motionArg."&".$httpAlarmAlarmArg."&".$urlArg, $camUser, $camPass);
			print_r($result);
			echo $result;
		} else {
			$motionArg = "motion_armed=0";
			$result = sendGet("http://192.168.9.208/set_alarm.cgi?".$motionArg, $camUser, $camPass);
			echo $result;
		}
	}
} else {
	if ($_GET["entity"] == "switch.larm_motion_foscam_black") {
                $result = sendGet("http://192.168.9.208/get_params.cgi", $camUser, $camPass);
		if (strpos($result, "alarm_motion_armed=1;") !== false) {
 			echo '{"state":"ON"}';
		} else {
                	echo '{"state":"OFF"}';
		}
        }
}

function sendGet($url, $user, $password) {
	$ch = curl_init();

	curl_setopt($ch, CURLOPT_URL,$url);
	curl_setopt($ch, CURLOPT_GET, 1);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1 );
	curl_setopt($ch, CURLOPT_VERBOSE, true);
	curl_setopt($ch, CURLOPT_USERPWD, $user . ":" . $password);
curl_setopt($ch, CURLOPT_VERBOSE, true);
$verbose = fopen('php://temp', 'w+');
curl_setopt($ch, CURLOPT_STDERR, $verbose);

$result=curl_exec ($ch);
/*
if ($result === FALSE) {
    printf("cUrl error (#%d): %s<br>\n", curl_errno($ch),
           htmlspecialchars(curl_error($ch)));
}*/

rewind($verbose);
$verboseLog = stream_get_contents($verbose);

//echo "Verbose information:\n<pre>", htmlspecialchars($verboseLog), "</pre>\n";


	return $result;
}

?>
