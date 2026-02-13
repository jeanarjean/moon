<?php

/**
 * Plugin Name:       [Bionaissance] Contact Lead Gen
 * Author:            junifia
 * Author URI:        https://junifia.ca
 * Requires at least: 6.4.3
 * Requires PHP:      7.4.33
 * Requires Plugins:  contact-form-7,woocommerce
 * Text Domain:       bio_contact-lead-gen
 * Domain Path:       /languages
 * License:           UNLICENSED
 *
 * @package         Bio_Contact_Lead_Gen
 */

// error_log("PHP Warning: lolivinny Warning in /home/q3s3vyijy7np/public_html/staging.bionaissance.ca/wp-content/plugins/bio_contact-lead-gen/bio_contact-lead-gen.php on line 18");

require_once WP_PLUGIN_DIR . '/bio_contact-lead-gen/includes/env.php';
require_once WP_PLUGIN_DIR . '/bio_contact-lead-gen/includes/fetch.php';
require_once WP_PLUGIN_DIR . '/bio_contact-lead-gen/includes/quote-validation.php';

define("BIO_LEAD_CONTACT_FORMS", ["request-for-quote", "lead-contact"]);
define("CONTACT_REASONS", [
  "request-for-quote" => "Demande une soumission sur mesure.",
  "lead-contact" => "Formulaire de Contact <br/> "
]);

// https://www.wpbeginner.com/wp-tutorials/how-to-easily-add-javascript-in-wordpress-pages-or-posts/
function enqueue_on_home()
{
  // if (is_page_template('template-homepage.php')) {
  $asset_file = include WP_PLUGIN_DIR . "/bio_contact-lead-gen/build/index.asset.php";
  wp_enqueue_script(
    'canadapost-addresscomplete-setup',
    plugins_url('build/index.js', __FILE__),
    $asset_file['dependencies'],
    $asset_file['version']
  );
  // }
}
add_action('wp_enqueue_scripts', 'enqueue_on_home');

function bio_contact_lead_gen_init()
{
  add_shortcode("lead-contact-form", "render_lead_contact_form");
}
add_action("init", "bio_contact_lead_gen_init");

function render_lead_contact_form($attributes, $content, $tag)
{
  $formTitle = $attributes['title'] ?? "lead-contact";
  if (!in_array($formTitle, BIO_LEAD_CONTACT_FORMS)) {
    return "<em>Erreur:</em> formulaire " . $attributes['title'] . " non supporté par Usoft";
  }

  ob_start();
?>
<?php echo apply_shortcodes("[contact-form-7 title=\"{$formTitle}\" html_class=\"bio_contact-form\"]");

  return ob_get_clean();
}

function push_lead_to_usoft($contact_form, &$abort, $submission)
{
  $formTitle = $contact_form->title();
  if (!in_array($formTitle, BIO_LEAD_CONTACT_FORMS)) {
    error_log("PHP Info: skipped lead push for form {$formTitle}");
    return;
  }
  $contactReason = CONTACT_REASONS[$formTitle];

  if (defined("CONTACT_EMAIL")) {
    $properties = $contact_form->get_properties();
    $properties['mail']['recipient'] = CONTACT_EMAIL;
    $contact_form->set_properties($properties);
  }

  $postalCode = $submission->get_posted_data('postal-code');
  $lawnAreaRange = apply_shortcodes(
    '[dim-calculate' .
      ' postcode="' . str_replace(' ', '', $postalCode) . '"' .
      ' street=' . $submission->get_posted_data('building-number') .
      // TODO: porte is supposedly the civic number suffix, but seems unused in dim-calculate, see functions.php@L30 $porte = $letters;
      ' porte=""' .
      ']'
  );
  $lawnCareServices = get_available_lawn_care_services($postalCode);

  $city = $submission->get_posted_data('city');
  $isCityServiced = is_city_serviced($city);

  $servicesArray = array();

  $quoteMessage = array_reduce(
    $lawnCareServices,
    function ($quotes, $service) use (&$lawnAreaRange, &$servicesArray) {
      $variation_id = $service->get_data_store()->find_matching_product_variation($service, [
        "attribute_pa_nombre-de-versements" => "1-versement",
        "attribute_pa_superficie" => $lawnAreaRange
      ]);

      if ($variation_id) {
        $title = $service->get_title();
        $price = $service->get_available_variation($variation_id)['display_price'];
        $quotes .= "<br/>- {$title}: {$price}$";
        $servicesArray[$service->get_id()] = $service->get_available_variation($variation_id)['display_price'];
      }
      return $quotes;
    },
    $isCityServiced
      ? "{$contactReason} Forfaits disponibles :"
      : "{$contactReason}<br/>*Ville non desservie. Forfaits potentiels :"
  );

  # Pour aération du so, , application de chaux et traitement préventif contre les vers blancs
  $ids = [18258, 18256, 18253];

  foreach ($ids as $id) {
    $service = wc_get_product($id);
    if ($service) {
		$variation_id = $service->get_data_store()->find_matching_product_variation($service, [
          "attribute_pa_superficie" => $lawnAreaRange
        ]);
        $servicesArray[$id] = $service->get_available_variation($variation_id)['display_price'];
    }
  }
	
	
  # gestion parasitaire extérieure
  $service = wc_get_product(18260);
  $servicesArray[18260] = floatval($service->get_price());

  $quoteMessage = "Demande d'être contacté: " . ($submission->get_posted_data('acceptance')[0] == 1 ? "Oui" : "Non") . " <br/> " . "Note: " . $submission->get_posted_data('notes') . " <br/> " . $quoteMessage;

  if(strlen($submission->get_posted_data('reason')) != 0) {
    $quoteMessage = "Raison: " . $submission->get_posted_data('reason') . " <br/>" . $quoteMessage; 
  }

  $names = explode(" ", $submission->get_posted_data('full-name'));
  $lead = [
    "FirstName" => array_shift($names),
    "LastName" =>  implode(" ", $names),
    "Email" =>  $submission->get_posted_data('email') ?? "",
    "Number" =>  $submission->get_posted_data('phone-number'),
    "Service" =>  "Traitement de pelouse",
    "City" => $submission->get_posted_data('city'),
    "Address" => $submission->get_posted_data('address-line1'),
    "Zip" => $postalCode,
    "Message" => $quoteMessage,
    "userNote" => $contactReason,
    "dimension" => $lawnAreaRange,
    "products" => $servicesArray
  ];

  $quote = [
    "lawnAreaRange" => $lawnAreaRange,
    "postalCode" => $postalCode,
    "isCityServiced" => $isCityServiced
  ];
  $submission->add_result_props(array("quote" => $quote, "formTitle" => $formTitle));
  $prettyQuote = print_r($quote, true);

  try {
    $body = fetch("POST", USOFT_LEAD_ENDPOINT, ["Content-Type: application/json"], json_encode($lead));

    error_log("PHP Debug: usoft response: {$body}");
    error_log("PHP Notice: added lead: {$prettyQuote}");
  } catch (Exception $e) {
    error_log("PHP Error: Failed to push lead to usoft {$prettyQuote}.\n {$e}");
  }
};

add_action('wpcf7_before_send_mail', 'push_lead_to_usoft', 10, 3);

