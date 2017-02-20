<?php

$sensor =  $_GET['sensor'];
$state = $_GET['state'];

if ($sensor == "cam.foscam.black.motion") {
	if ($state == "on") {
		$state = "on";
	} else {
		$state = "off";
	}
	$sensor_id = "binary_sensor.cam_foscam_black_motion";
} else {
	exit();
}


$body = '{"state": "'.$state.'"}';
echo $body;
echo $sensor_id;

$ch = curl_init();

curl_setopt($ch, CURLOPT_URL,"http://localhost/api/states/" . $sensor_id);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_PORT, 8123);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1 );
curl_setopt($ch, CURLOPT_POSTFIELDS, '{"state": "'.$state.'"}' );
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json', 'x-ha-access: hasspassGislaved'));
curl_setopt($ch, CURLOPT_VERBOSE, true);
$verbose = fopen('php://temp', 'w+');
curl_setopt($ch, CURLOPT_STDERR, $verbose);

$result=curl_exec ($ch);

if ($result === FALSE) {
    printf("cUrl error (#%d): %s<br>\n", curl_errno($ch),
           htmlspecialchars(curl_error($ch)));
}

rewind($verbose);
$verboseLog = stream_get_contents($verbose);

echo "Verbose information:\n<pre>", htmlspecialchars($verboseLog), "</pre>\n";

print_r($result);
echo "Done";

?>
