<?php
// Check for empty fields
if(empty($_POST['name'])  		||
   empty($_POST['email']) 		||
   empty($_POST['phone']) 		||
   empty($_POST['message'])	||
   !filter_var($_POST['email'],FILTER_VALIDATE_EMAIL))
   {
	echo "Brak danych!";
	return false;
   }

$name = $_POST['name'];
$email_address = $_POST['email'];
$phone = $_POST['phone'];
$message = $_POST['message'];

// Create the email and send the message
$to = 'mirkajdor@wp.pl';
$email_subject = "Kontakt z Internetów:  $name";
$email_body = "Jest to informacja wysłana z formularza kontaktowego na twojej stronie.\n\n"."A tutaj jej szczegóły:\n\nImię i Nazwisko: $name\n\nEmail Adres: $email_address\n\nNumer Telefonu: $phone\n\nWiadomość:\n$message";
$headers = "From: noreply@yourdomain.com\n";
$headers .= "Reply-To: $email_address";
mail($to,$email_subject,$email_body,$headers);
return true;
?>
