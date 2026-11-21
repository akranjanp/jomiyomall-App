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

        return rest_ensure_response([
            'status' => 'success',
            'app_name' => 'Jomiyo Mall',
            'website_url' => get_site_url(),
            'currency' => get_woocommerce_currency(),
            'currency_symbol' => html_entity_decode(get_woocommerce_currency_symbol()),
            'support_email' => get_option('admin_email'),
            'support_phone' => '+91 9876543210',
            'whatsapp_number' => '+919876543210',
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

    public function add_admin_menu() {
        add_options_page('Mobile Commerce API', 'Mobile App API', 'manage_options', 'mobile-commerce-api', [$this, 'render_admin_page']);
    }

    public function register_settings() {
        register_setting('jomiyo_mobile_settings', 'woocommerce_razorpay_key_id');
        register_setting('jomiyo_mobile_settings', 'woocommerce_razorpay_key_secret');
    }

    public function render_admin_page() {
        ?>
        <div class="wrap">
            <h1>Mobile Commerce API Bridge Settings</h1>
            <p>Configure backend settings for Jomiyo Mall Mobile Application.</p>
            <form method="post" action="options.php">
                <?php settings_fields('jomiyo_mobile_settings'); ?>
                <table class="form-table">
                    <tr>
                        <th scope="row">Razorpay Key ID</th>
                        <td><input type="text" name="woocommerce_razorpay_key_id" value="<?php echo esc_attr(get_option('woocommerce_razorpay_key_id')); ?>" class="regular-text" /></td>
                    </tr>
                    <tr>
                        <th scope="row">Razorpay Key Secret</th>
                        <td><input type="password" name="woocommerce_razorpay_key_secret" value="<?php echo esc_attr(get_option('woocommerce_razorpay_key_secret')); ?>" class="regular-text" /></td>
                    </tr>
                </table>
                <?php submit_button(); ?>
            </form>
        </div>
        <?php
    }
}

new Jomiyo_Mobile_API_Bridge();
