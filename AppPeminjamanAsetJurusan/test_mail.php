<?php
ini_set( 'display_errors', 1 );
error_reporting( E_ALL );
$from = "test@example.com";
$to = "test@example.com";
$subject = "PHP Mail Test script";
$message = "This is a test to check the PHP Mail functionality";
$headers = "From:" . $from;
if(mail($to,$subject,$message, $headers)) {
    echo "Test email sent successfully";
} else {
    echo "Failed to send test email";
}
?>