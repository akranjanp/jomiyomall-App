<?php
/**
 * Plugin Name: Mobile Commerce API Bridge
 * Plugin URI: https://jomiyomall.com
 * Description: Secure REST API Bridge for Jomiyo Mall Flutter E-Commerce Application. Provides endpoints for customer authentication, homepage banners, dynamic sections, wishlist sync, and Razorpay payment verification.
 * Version: 1.0.0
 * Author: Jomiyo Mall Engineering Team
 * Author URI: https://jomiyomall.com
 * Text Domain: mobile-commerce-api-bridge
 * Requires at least: 5.8
 * Requires PHP: 7.4
 * WC requires at least: 6.0
 */

if (!defined('ABSPATH')) {
    exit; // Exit if accessed directly
}

class Jomiyo_Mobile_API_Bridge {

    const NAMESPACE = 'jomiyo/v1';

    public function __construct() {
        add_action('rest_api_init', [$this, 'register_routes']);
        add_action('admin_menu', [$this, 'add_admin_menu']);
        add_action('admin_init', [$this, 'register_settings']);
        add_action('admin_enqueue_scripts', [$this, 'enqueue_admin_scripts']);
    }

    public function register_routes() {
        // App Config & Banners
        register_rest_route(self::NAMESPACE, '/config', [
            'methods'  => 'GET',
            'callback' => [$this, 'get_app_config'],
            'permission_callback' => '__return_true',
        ]);

        // Authentication Endpoints
        register_rest_route(self::NAMESPACE, '/auth/register', [
            'methods'  => 'POST',
            'callback' => [$this, 'handle_register'],
            'permission_callback' => '__return_true',
        ]);

        register_rest_route(self::NAMESPACE, '/auth/login', [
            'methods'  => 'POST',
            'callback' => [$this, 'handle_login'],
            'permission_callback' => '__return_true',
        ]);

        register_rest_route(self::NAMESPACE, '/auth/me', [
            'methods'  => 'GET',
            'callback' => [$this, 'get_current_user_profile'],
            'permission_callback' => [$this, 'verify_token_permission'],
        ]);

        register_rest_route(self::NAMESPACE, '/auth/update-profile', [
            'methods'  => 'POST',
            'callback' => [$this, 'update_user_profile'],
            'permission_callback' => [$this, 'verify_token_permission'],
        ]);

        // Wishlist Endpoints
        register_rest_route(self::NAMESPACE, '/wishlist', [
            'methods'  => 'GET',
            'callback' => [$this, 'get_user_wishlist'],
            'permission_callback' => [$this, 'verify_token_permission'],
        ]);

        register_rest_route(self::NAMESPACE, '/wishlist', [
            'methods'  => 'POST',
            'callback' => [$this, 'update_user_wishlist'],
            'permission_callback' => [$this, 'verify_token_permission'],
        ]);

        // Razorpay Payment Endpoints
        register_rest_route(self::NAMESPACE, '/razorpay/create-order', [
            'methods'  => 'POST',
            'callback' => [$this, 'create_razorpay_order'],
            'permission_callback' => '__return_true',
        ]);

        register_rest_route(self::NAMESPACE, '/razorpay/verify-payment', [
            'methods'  => 'POST',
            'callback' => [$this, 'verify_razorpay_payment'],
            'permission_callback' => '__return_true',
        ]);
    }

    /**
     * App Config, Banners, and Dynamic Sections
     */
    public function get_app_config() {
        $banners = get_option('jomiyo_mobile_banners', [
            [
                'id' => 1,
                'title' => 'Big Festive Sale',
                'subtitle' => 'Up to 60% OFF on Top Brands',
                'image' => 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=1200',
                'action_type' => 'category',
                'action_value' => 'sale',
            ],
            [
                'id' => 2,
                'title' => 'Trendy Fashion Collection',
                'subtitle' => 'Explore the Latest Arrivals',
                'image' => 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=1200',
                'action_type' => 'category',
                'action_value' => 'fashion',
            ],
            [
                'id' => 3,
                'title' => 'Premium Footwear & Accessories',
                'subtitle' => 'Elevate Your Style',
                'image' => 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=1200',
                'action_type' => 'category',
                'action_value' => 'shoes',
            ],
        ]);

        $sections = [
            ['id' => 'featured', 'title' => 'Featured Products', 'type' => 'featured', 'limit' => 8],
            ['id' => 'popular_categories', 'title' => 'Shop By Category', 'type' => 'categories', 'limit' => 6],
            ['id' => 'on_sale', 'title' => 'Mega Discounts & Offers', 'type' => 'on_sale', 'limit' => 8],
            ['id' => 'latest', 'title' => 'New Arrivals', 'type' => 'latest', 'limit' => 8],
            ['id' => 'best_sellers', 'title' => 'Best Sellers', 'type' => 'best_sellers', 'limit' => 8],
        ];

        $whatsapp = get_option('jomiyo_mobile_whatsapp', '+919910403750');
        $phone = get_option('jomiyo_mobile_support_phone', '+91 9910403750');

        return rest_ensure_response([
            'status' => 'success',
            'app_name' => 'Jomiyo Mall',
            'website_url' => get_site_url(),
            'currency' => get_woocommerce_currency(),
            'currency_symbol' => html_entity_decode(get_woocommerce_currency_symbol()),
            'support_email' => get_option('admin_email'),
            'support_phone' => !empty($phone) ? $phone : '+91 9910403750',
            'whatsapp_number' => !empty($whatsapp) ? $whatsapp : '+919910403750',
            'min_version' => '1.0.0',
            'latest_version' => '1.0.0',
            'maintenance_mode' => false,
            'banners' => $banners,
            'sections' => $sections,
        ]);
    }

    /**
     * Customer Registration
     */
    public function handle_register($request) {
        $params = $request->get_json_params();
        $email = sanitize_email($params['email'] ?? '');
        $password = $params['password'] ?? '';
        $first_name = sanitize_text_field($params['first_name'] ?? '');
        $last_name = sanitize_text_field($params['last_name'] ?? '');
        $phone = sanitize_text_field($params['phone'] ?? '');

        if (empty($email) || !is_email($email)) {
            return new WP_Error('invalid_email', 'Please provide a valid email address.', ['status' => 400]);
        }

        if (empty($password) || strlen($password) < 6) {
            return new WP_Error('invalid_password', 'Password must be at least 6 characters long.', ['status' => 400]);
        }

        if (email_exists($email)) {
            return new WP_Error('email_exists', 'An account is already registered with this email.', ['status' => 409]);
        }

        $username = sanitize_user(current(explode('@', $email)));
        $i = 1;
        $base_username = $username;
        while (username_exists($username)) {
            $username = $base_username . $i++;
        }

        $user_id = wp_create_user($username, $password, $email);

        if (is_wp_error($user_id)) {
            return new WP_Error('registration_failed', $user_id->get_error_message(), ['status' => 500]);
        }

        // Set customer role
        $user = new WP_User($user_id);
        $user->set_role('customer');

        // Update profile
        wp_update_user([
            'ID' => $user_id,
            'first_name' => $first_name,
            'last_name' => $last_name,
            'display_name' => trim("$first_name $last_name") ?: $username,
        ]);

        if (!empty($phone)) {
            update_user_meta($user_id, 'billing_phone', $phone);
        }

        $token = $this->generate_token($user_id);

        return rest_ensure_response([
            'status' => 'success',
            'message' => 'Registration successful.',
            'token' => $token,
            'user' => $this->format_user_data($user_id),
        ]);
    }

    /**
     * Customer Login
     */
    public function handle_login($request) {
        $params = $request->get_json_params();
        $username_or_email = sanitize_text_field($params['username'] ?? $params['email'] ?? '');
        $password = $params['password'] ?? '';

        if (empty($username_or_email) || empty($password)) {
            return new WP_Error('missing_fields', 'Please provide email/username and password.', ['status' => 400]);
        }

        $user = wp_authenticate($username_or_email, $password);

        if (is_wp_error($user)) {
            return new WP_Error('invalid_credentials', 'Invalid username/email or password.', ['status' => 401]);
        }

        $token = $this->generate_token($user->ID);

        return rest_ensure_response([
            'status' => 'success',
            'message' => 'Login successful.',
            'token' => $token,
            'user' => $this->format_user_data($user->ID),
        ]);
    }

    /**
     * Get Current Profile
     */
    public function get_current_user_profile($request) {
        $user_id = $request->get_param('auth_user_id');
        return rest_ensure_response([
            'status' => 'success',
            'user' => $this->format_user_data($user_id),
        ]);
    }

    /**
     * Update Profile
     */
    public function update_user_profile($request) {
        $user_id = $request->get_param('auth_user_id');
        $params = $request->get_json_params();

        $update_data = ['ID' => $user_id];
        if (!empty($params['first_name'])) {
            $update_data['first_name'] = sanitize_text_field($params['first_name']);
        }
        if (!empty($params['last_name'])) {
            $update_data['last_name'] = sanitize_text_field($params['last_name']);
        }
        if (!empty($params['display_name'])) {
            $update_data['display_name'] = sanitize_text_field($params['display_name']);
        }

        wp_update_user($update_data);

        // Update billing/shipping addresses if provided
        $address_fields = [
            'billing_first_name', 'billing_last_name', 'billing_address_1', 'billing_address_2',
            'billing_city', 'billing_state', 'billing_postcode', 'billing_country', 'billing_phone', 'billing_email',
            'shipping_first_name', 'shipping_last_name', 'shipping_address_1', 'shipping_address_2',
            'shipping_city', 'shipping_state', 'shipping_postcode', 'shipping_country',
        ];

        foreach ($address_fields as $field) {
            if (isset($params[$field])) {
                update_user_meta($user_id, $field, sanitize_text_field($params[$field]));
            }
        }

        return rest_ensure_response([
            'status' => 'success',
            'message' => 'Profile updated successfully.',
            'user' => $this->format_user_data($user_id),
        ]);
    }

    /**
     * Wishlist Management
     */
    public function get_user_wishlist($request) {
        $user_id = $request->get_param('auth_user_id');
        $wishlist = get_user_meta($user_id, 'jomiyo_wishlist_ids', true) ?: [];
        return rest_ensure_response([
            'status' => 'success',
            'product_ids' => array_values(array_filter(array_map('intval', $wishlist))),
        ]);
    }

    public function update_user_wishlist($request) {
        $user_id = $request->get_param('auth_user_id');
        $params = $request->get_json_params();
        $product_ids = $params['product_ids'] ?? [];

        if (!is_array($product_ids)) {
            $product_ids = [];
        }

        $clean_ids = array_values(array_unique(array_filter(array_map('intval', $product_ids))));
        update_user_meta($user_id, 'jomiyo_wishlist_ids', $clean_ids);

        return rest_ensure_response([
            'status' => 'success',
            'product_ids' => $clean_ids,
        ]);
    }

    /**
     * Razorpay: Create Order
     */
    public function create_razorpay_order($request) {
        $params = $request->get_json_params();
        $order_id = intval($params['order_id'] ?? 0);

        if (!$order_id) {
            return new WP_Error('missing_order_id', 'Valid WooCommerce Order ID required.', ['status' => 400]);
        }

        $order = wc_get_order($order_id);
        if (!$order) {
            return new WP_Error('order_not_found', 'Order not found.', ['status' => 404]);
        }

        $key_id = get_option('woocommerce_razorpay_key_id', '');
        $key_secret = get_option('woocommerce_razorpay_key_secret', '');

        // Amount in paise
        $amount_paise = round($order->get_total() * 100);
        $receipt = 'order_rcptid_' . $order_id;

        // Call Razorpay API
        $response = wp_remote_post('https://api.razorpay.com/v1/orders', [
            'headers' => [
                'Authorization' => 'Basic ' . base64_encode("$key_id:$key_secret"),
                'Content-Type' => 'application/json',
            ],
            'body' => json_encode([
                'amount' => $amount_paise,
                'currency' => $order->get_currency() ?: 'INR',
                'receipt' => $receipt,
                'payment_capture' => 1,
            ]),
            'timeout' => 20,
        ]);

        if (is_wp_error($response)) {
            return new WP_Error('razorpay_api_error', $response->get_error_message(), ['status' => 500]);
        }

        $body = json_decode(wp_remote_retrieve_body($response), true);
        if (isset($body['error'])) {
            return new WP_Error('razorpay_failed', $body['error']['description'] ?? 'Failed to create Razorpay order', ['status' => 400]);
        }

        $razorpay_order_id = $body['id'];
        $order->update_meta_data('_razorpay_order_id', $razorpay_order_id);
        $order->save();

        return rest_ensure_response([
            'status' => 'success',
            'razorpay_order_id' => $razorpay_order_id,
            'amount' => $amount_paise,
            'currency' => $order->get_currency(),
            'key_id' => $key_id,
        ]);
    }

    /**
     * Razorpay: Verify Payment Signature & Update Order
     */
    public function verify_razorpay_payment($request) {
        $params = $request->get_json_params();
        $order_id = intval($params['order_id'] ?? 0);
        $razorpay_order_id = sanitize_text_field($params['razorpay_order_id'] ?? '');
        $razorpay_payment_id = sanitize_text_field($params['razorpay_payment_id'] ?? '');
        $razorpay_signature = sanitize_text_field($params['razorpay_signature'] ?? '');

        if (!$order_id || !$razorpay_order_id || !$razorpay_payment_id || !$razorpay_signature) {
            return new WP_Error('missing_payment_params', 'Incomplete payment parameters.', ['status' => 400]);
        }

        $order = wc_get_order($order_id);
        if (!$order) {
            return new WP_Error('order_not_found', 'Order not found.', ['status' => 404]);
        }

        $key_secret = get_option('woocommerce_razorpay_key_secret', '');

        // HMAC-SHA256 verification
        $expected_signature = hash_hmac('sha256', "$razorpay_order_id|$razorpay_payment_id", $key_secret);

        if (!hash_equals($expected_signature, $razorpay_signature)) {
            return new WP_Error('signature_mismatch', 'Payment signature verification failed.', ['status' => 400]);
        }

        // Signature is valid! Update WooCommerce order
        $order->payment_complete($razorpay_payment_id);
        $order->add_order_note(sprintf('Razorpay Mobile App Payment Successful. Payment ID: %s, Order ID: %s', $razorpay_payment_id, $razorpay_order_id));
        $order->update_meta_data('_razorpay_payment_id', $razorpay_payment_id);
        $order->save();

        return rest_ensure_response([
            'status' => 'success',
            'message' => 'Payment verified and order updated successfully.',
            'order_id' => $order_id,
            'order_status' => $order->get_status(),
        ]);
    }

    /**
     * Helper: Format User Data
     */
    private function format_user_data($user_id) {
        $user = get_userdata($user_id);
        if (!$user) return null;

        return [
            'id' => $user->ID,
            'username' => $user->user_login,
            'email' => $user->user_email,
            'first_name' => $user->first_name,
            'last_name' => $user->last_name,
            'display_name' => $user->display_name,
            'phone' => get_user_meta($user_id, 'billing_phone', true) ?: '',
            'billing' => [
                'first_name' => get_user_meta($user_id, 'billing_first_name', true) ?: $user->first_name,
                'last_name' => get_user_meta($user_id, 'billing_last_name', true) ?: $user->last_name,
                'address_1' => get_user_meta($user_id, 'billing_address_1', true) ?: '',
                'address_2' => get_user_meta($user_id, 'billing_address_2', true) ?: '',
                'city' => get_user_meta($user_id, 'billing_city', true) ?: '',
                'state' => get_user_meta($user_id, 'billing_state', true) ?: '',
                'postcode' => get_user_meta($user_id, 'billing_postcode', true) ?: '',
                'country' => get_user_meta($user_id, 'billing_country', true) ?: 'IN',
                'email' => get_user_meta($user_id, 'billing_email', true) ?: $user->user_email,
                'phone' => get_user_meta($user_id, 'billing_phone', true) ?: '',
            ],
            'shipping' => [
                'first_name' => get_user_meta($user_id, 'shipping_first_name', true) ?: $user->first_name,
                'last_name' => get_user_meta($user_id, 'shipping_last_name', true) ?: $user->last_name,
                'address_1' => get_user_meta($user_id, 'shipping_address_1', true) ?: '',
                'address_2' => get_user_meta($user_id, 'shipping_address_2', true) ?: '',
                'city' => get_user_meta($user_id, 'shipping_city', true) ?: '',
                'state' => get_user_meta($user_id, 'shipping_state', true) ?: '',
                'postcode' => get_user_meta($user_id, 'shipping_postcode', true) ?: '',
                'country' => get_user_meta($user_id, 'shipping_country', true) ?: 'IN',
            ],
        ];
    }

    /**
     * Generate HMAC token for authenticated session
     */
    private function generate_token($user_id) {
        $secret = wp_salt('auth');
        $issued_at = time();
        $payload = "$user_id|$issued_at";
        $signature = hash_hmac('sha256', $payload, $secret);
        return base64_encode("$payload|$signature");
    }

    /**
     * Verify token from Authorization header
     */
    public function verify_token_permission($request) {
        $auth_header = $request->get_header('Authorization');
        if (empty($auth_header)) {
            return new WP_Error('no_auth_header', 'Authorization header is missing.', ['status' => 401]);
        }

        $token = str_replace('Bearer ', '', trim($auth_header));
        $decoded = base64_decode($token);
        $parts = explode('|', $decoded);

        if (count($parts) !== 3) {
            return new WP_Error('invalid_token', 'Malformed authentication token.', ['status' => 401]);
        }

        list($user_id, $issued_at, $signature) = $parts;
        $secret = wp_salt('auth');
        $expected_sig = hash_hmac('sha256', "$user_id|$issued_at", $secret);

        if (!hash_equals($expected_sig, $signature)) {
            return new WP_Error('invalid_signature', 'Token signature verification failed.', ['status' => 401]);
        }

        // Expire token after 30 days
        if (time() - intval($issued_at) > (30 * DAY_IN_SECONDS)) {
            return new WP_Error('token_expired', 'Token has expired. Please login again.', ['status' => 401]);
        }

        $request->set_param('auth_user_id', intval($user_id));
        return true;
    }

    public function enqueue_admin_scripts($hook) {
        if (strpos($hook, 'mobile-commerce-api') !== false) {
            wp_enqueue_media();
        }
    }

    public function add_admin_menu() {
        add_menu_page(
            'Jomiyo Mobile App',
            'Mobile App API',
            'manage_options',
            'mobile-commerce-api',
            [$this, 'render_admin_page'],
            'dashicons-smartphone',
            58
        );
    }

    public function register_settings() {
        register_setting('jomiyo_mobile_settings', 'woocommerce_razorpay_key_id');
        register_setting('jomiyo_mobile_settings', 'woocommerce_razorpay_key_secret');
        register_setting('jomiyo_mobile_settings', 'jomiyo_mobile_whatsapp');
        register_setting('jomiyo_mobile_settings', 'jomiyo_mobile_support_phone');
    }

    public function render_admin_page() {
        // Handle Form Submission
        if (isset($_POST['jomiyo_save_settings']) && check_admin_referer('jomiyo_mobile_save_action', 'jomiyo_mobile_nonce')) {
            $submitted_banners = [];
            if (isset($_POST['banners']) && is_array($_POST['banners'])) {
                foreach ($_POST['banners'] as $idx => $b) {
                    $img = esc_url_raw($b['image'] ?? '');
                    if (!empty($img)) {
                        $submitted_banners[] = [
                            'id' => $idx + 1,
                            'title' => sanitize_text_field($b['title'] ?? ''),
                            'subtitle' => sanitize_text_field($b['subtitle'] ?? ''),
                            'image' => $img,
                            'action_type' => sanitize_text_field($b['action_type'] ?? 'category'),
                            'action_value' => sanitize_text_field($b['action_value'] ?? ''),
                        ];
                    }
                }
            }

            if (!empty($submitted_banners)) {
                update_option('jomiyo_mobile_banners', $submitted_banners);
            }

            update_option('woocommerce_razorpay_key_id', sanitize_text_field($_POST['woocommerce_razorpay_key_id'] ?? ''));
            update_option('woocommerce_razorpay_key_secret', sanitize_text_field($_POST['woocommerce_razorpay_key_secret'] ?? ''));
            update_option('jomiyo_mobile_whatsapp', sanitize_text_field($_POST['jomiyo_mobile_whatsapp'] ?? ''));
            update_option('jomiyo_mobile_support_phone', sanitize_text_field($_POST['jomiyo_mobile_support_phone'] ?? ''));

            echo '<div class="notice notice-success is-dismissible" style="margin-top:15px;"><p><strong>Success:</strong> Mobile App settings and Home Screen Banners saved successfully! Mobile App will now display your updated banners.</p></div>';
        }

        $banners = get_option('jomiyo_mobile_banners', [
            [
                'id' => 1,
                'title' => 'Big Festive Sale',
                'subtitle' => 'Up to 60% OFF on Top Brands',
                'image' => 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=1200',
                'action_type' => 'category',
                'action_value' => 'sale',
            ],
            [
                'id' => 2,
                'title' => 'Trendy Fashion Collection',
                'subtitle' => 'Explore the Latest Arrivals',
                'image' => 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=1200',
                'action_type' => 'category',
                'action_value' => 'fashion',
            ],
            [
                'id' => 3,
                'title' => 'Premium Footwear & Accessories',
                'subtitle' => 'Elevate Your Style',
                'image' => 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=1200',
                'action_type' => 'category',
                'action_value' => 'shoes',
            ],
        ]);

        $razorpay_key_id = get_option('woocommerce_razorpay_key_id', 'rzp_test_SDo2WKBNQXDk5Y');
        $razorpay_key_secret = get_option('woocommerce_razorpay_key_secret', '');
        $whatsapp = get_option('jomiyo_mobile_whatsapp', '+919910403750');
        $phone = get_option('jomiyo_mobile_support_phone', '+91 9910403750');
        ?>
        <div class="wrap" style="max-width: 960px;">
            <h1 style="display:flex; align-items:center; gap:10px;">
                <span class="dashicons dashicons-smartphone" style="font-size:32px; width:32px; height:32px; color:#0037AB;"></span>
                Jomiyo Mobile App Manager
            </h1>
            <p style="font-size:14px; color:#555;">Manage dynamic Home Screen Banners, promotional offers, Razorpay verification, and customer support directly for the Jomiyo Mall mobile app.</p>

            <form method="post" action="">
                <?php wp_nonce_field('jomiyo_mobile_save_action', 'jomiyo_mobile_nonce'); ?>

                <!-- BANNERS CARD -->
                <div style="background:#fff; border:1px solid #ccd0d4; border-radius:8px; padding:20px; margin-bottom:24px; box-shadow:0 1px 3px rgba(0,0,0,0.05);">
                    <h2 style="margin-top:0; border-bottom:1px solid #eee; padding-bottom:10px; color:#0037AB;">
                        🖼️ Home Screen Hero Banners
                    </h2>
                    <p style="color:#666; font-size:13px;">Add, replace, or update banners shown on the Mobile App Home Screen carousel. You can upload new images or pick from your existing Media Library.</p>

                    <div id="jomiyo-banners-container">
                        <?php 
                        for ($i = 0; $i < 5; $i++): 
                            $b = isset($banners[$i]) ? $banners[$i] : ['title' => '', 'subtitle' => '', 'image' => '', 'action_type' => 'category', 'action_value' => ''];
                        ?>
                            <div class="jomiyo-banner-card" style="background:#f9fafb; border:1px solid #e5e7eb; border-radius:6px; padding:16px; margin-bottom:16px;">
                                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                                    <h3 style="margin:0; font-size:14px; color:#111827;">Slide #<?php echo ($i + 1); ?></h3>
                                    <?php if (!empty($b['image'])): ?>
                                        <span style="font-size:11px; background:#e0e7ff; color:#3730a3; padding:2px 8px; border-radius:10px; font-weight:600;">Active</span>
                                    <?php else: ?>
                                        <span style="font-size:11px; background:#f3f4f6; color:#6b7280; padding:2px 8px; border-radius:10px;">Optional</span>
                                    <?php endif; ?>
                                </div>

                                <div style="display:grid; grid-template-columns: 180px 1fr; gap:16px; align-items:start;">
                                    <!-- Image Preview & Uploader -->
                                    <div style="text-align:center;">
                                        <div style="width:100%; height:95px; background:#e5e7eb; border-radius:6px; overflow:hidden; display:flex; align-items:center; justify-content:center; margin-bottom:8px; border:1px solid #d1d5db;">
                                            <img id="preview_banner_<?php echo $i; ?>" src="<?php echo esc_url($b['image']); ?>" style="width:100%; height:100%; object-fit:cover; display:<?php echo !empty($b['image']) ? 'block' : 'none'; ?>;" alt="Preview" />
                                            <span id="placeholder_banner_<?php echo $i; ?>" style="color:#9ca3af; font-size:12px; display:<?php echo empty($b['image']) ? 'block' : 'none'; ?>;">No Image</span>
                                        </div>
                                        <input type="hidden" name="banners[<?php echo $i; ?>][image]" id="input_banner_<?php echo $i; ?>" value="<?php echo esc_attr($b['image']); ?>" />
                                        <button type="button" class="button jomiyo-upload-btn" data-target="<?php echo $i; ?>" style="font-size:12px; width:100%;">
                                            📁 <?php echo empty($b['image']) ? 'Upload Image' : 'Change Image'; ?>
                                        </button>
                                    </div>

                                    <!-- Banner Fields -->
                                    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px;">
                                        <div>
                                            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">Banner Title</label>
                                            <input type="text" name="banners[<?php echo $i; ?>][title]" value="<?php echo esc_attr($b['title']); ?>" placeholder="e.g. Mega Summer Sale" style="width:100%; font-size:13px;" />
                                        </div>
                                        <div>
                                            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">Subtitle / Offer</label>
                                            <input type="text" name="banners[<?php echo $i; ?>][subtitle]" value="<?php echo esc_attr($b['subtitle']); ?>" placeholder="e.g. Up to 50% OFF" style="width:100%; font-size:13px;" />
                                        </div>
                                        <div>
                                            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">Click Action</label>
                                            <select name="banners[<?php echo $i; ?>][action_type]" style="width:100%; font-size:13px;">
                                                <option value="category" <?php selected($b['action_type'] ?? '', 'category'); ?>>Open Category</option>
                                                <option value="product" <?php selected($b['action_type'] ?? '', 'product'); ?>>Open Specific Product</option>
                                                <option value="none" <?php selected($b['action_type'] ?? '', 'none'); ?>>None (Banner Only)</option>
                                            </select>
                                        </div>
                                        <div>
                                            <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">Category Slug or Product ID</label>
                                            <input type="text" name="banners[<?php echo $i; ?>][action_value]" value="<?php echo esc_attr($b['action_value'] ?? ''); ?>" placeholder="e.g. men, women, or 212" style="width:100%; font-size:13px;" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        <?php endfor; ?>
                    </div>
                </div>

                <!-- INTEGRATION & SUPPORT CARD -->
                <div style="background:#fff; border:1px solid #ccd0d4; border-radius:8px; padding:20px; margin-bottom:24px; box-shadow:0 1px 3px rgba(0,0,0,0.05);">
                    <h2 style="margin-top:0; border-bottom:1px solid #eee; padding-bottom:10px; color:#0037AB;">
                        ⚙️ Payments & Support Settings
                    </h2>

                    <table class="form-table" style="margin-top:0;">
                        <tr>
                            <th scope="row"><label for="razorpay_key">Razorpay Key ID</label></th>
                            <td>
                                <input type="text" name="woocommerce_razorpay_key_id" id="razorpay_key" value="<?php echo esc_attr($razorpay_key_id); ?>" class="regular-text" />
                                <p class="description">Live Razorpay Key ID used for online payments in the app.</p>
                            </td>
                        </tr>
                        <tr>
                            <th scope="row"><label for="razorpay_secret">Razorpay Key Secret</label></th>
                            <td>
                                <input type="password" name="woocommerce_razorpay_key_secret" id="razorpay_secret" value="<?php echo esc_attr($razorpay_key_secret); ?>" class="regular-text" />
                                <p class="description">Used on the server to securely verify payment signatures and auto-update order statuses.</p>
                            </td>
                        </tr>
                        <tr>
                            <th scope="row"><label for="whatsapp_number">Customer Support WhatsApp</label></th>
                            <td>
                                <input type="text" name="jomiyo_mobile_whatsapp" id="whatsapp_number" value="<?php echo esc_attr($whatsapp); ?>" class="regular-text" placeholder="+919910403750" />
                                <p class="description">Number opened when customers tap the WhatsApp Support button in the app.</p>
                            </td>
                        </tr>
                        <tr>
                            <th scope="row"><label for="support_phone">Toll-Free / Support Phone</label></th>
                            <td>
                                <input type="text" name="jomiyo_mobile_support_phone" id="support_phone" value="<?php echo esc_attr($phone); ?>" class="regular-text" placeholder="+91 9910403750" />
                                <p class="description">Phone number opened when customers tap Call Support.</p>
                            </td>
                        </tr>
                    </table>
                </div>

                <p class="submit">
                    <button type="submit" name="jomiyo_save_settings" class="button button-primary button-hero" style="background:#0037AB; border-color:#002275;">
                        💾 Save Mobile App Changes
                    </button>
                </p>
            </form>
        </div>

        <script>
        jQuery(document).ready(function($){
            $('.jomiyo-upload-btn').click(function(e) {
                e.preventDefault();
                var targetIdx = $(this).data('target');
                var customUploader = wp.media({
                    title: 'Select Mobile App Banner Image',
                    button: { text: 'Use this Image' },
                    multiple: false
                }).on('select', function() {
                    var attachment = customUploader.state().get('selection').first().toJSON();
                    $('#input_banner_' + targetIdx).val(attachment.url);
                    $('#preview_banner_' + targetIdx).attr('src', attachment.url).show();
                    $('#placeholder_banner_' + targetIdx).hide();
                }).open();
            });
        });
        </script>
        <?php
    }
}

new Jomiyo_Mobile_API_Bridge();
