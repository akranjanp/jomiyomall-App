# Jomiyo Mall — WordPress Plugin Setup Guide

This guide explains how to install, activate, and configure the custom **Mobile Commerce API Bridge** companion plugin on your WordPress / WooCommerce store (`https://jomiyomall.com`).

---

## 1. Plugin Overview

The plugin file is located at:
`jomiyo_mall/wordpress-plugin/mobile-commerce-api-bridge.zip`

### Why This Plugin is Required:
1. **Secure Mobile Authentication**: Standard WooCommerce REST API does not provide a direct mobile-friendly email/password login endpoint that returns user metadata without third-party plugins.
2. **Dynamic Banners & Layouts**: Allows administrators to update home carousel slides, promotion banners, and announcements directly from the WordPress dashboard without requiring app store updates.
3. **Optimized Multi-Vendor Support**: Aggregates WCFM vendor data and product attributes for fast mobile consumption.
4. **Server-Side Payment Tokenization**: Communicates with Razorpay API using server-side secrets so secret keys are never exposed in the client APK.

---

## 2. Installation via WordPress Admin

1. Log into your WordPress Admin Dashboard at `https://jomiyomall.com/wp-admin`.
2. In the left sidebar, navigate to **Plugins** → **Add New Plugin**.
3. At the top of the screen, click the **Upload Plugin** button.
4. Click **Choose File** and select:
   `/Users/ashishranjan/.gemini/antigravity/scratch/jomiyo_mall/wordpress-plugin/mobile-commerce-api-bridge.zip`
5. Click **Install Now**.
6. Once uploaded, click **Activate Plugin**.

---

## 3. Manual Installation via SFTP / cPanel File Manager

If you prefer installing via cPanel or SFTP:
1. Extract `mobile-commerce-api-bridge.zip` to your computer. You will have a folder named `mobile-commerce-api-bridge`.
2. Upload the `mobile-commerce-api-bridge` directory to your WordPress installation directory:
   `wp-content/plugins/mobile-commerce-api-bridge/`
3. Log into WordPress Admin, go to **Plugins** → **Installed Plugins**, and click **Activate** under **Jomiyo Mall - Mobile Commerce API Bridge**.

---

## 4. WooCommerce REST API Verification

To ensure the mobile app can read product categories and catalog items:
1. Navigate to **WooCommerce** → **Settings** → **Advanced** → **REST API**.
2. Click **Add Key**.
3. **Description**: `Jomiyo Mall Mobile App`
4. **User**: Select an Administrator account.
5. **Permissions**: `Read/Write` (or `Read` for catalog).
6. Click **Generate API Key**.
7. Ensure the generated Consumer Key matches `ApiConstants.consumerKey` in `lib/app/config/api_constants.dart`.

---

## 5. Permalinks Configuration

The WordPress REST API requires "Pretty Permalinks" to be active:
1. In WordPress Admin, go to **Settings** → **Permalinks**.
2. Under **Common Settings**, select **Post name** (e.g. `https://jomiyomall.com/sample-post/`).
3. Click **Save Changes**.
4. Test the endpoint in your browser or curl:
   ```bash
   curl -I https://jomiyomall.com/wp-json/jomiyo/v1/config
   ```
   *Expected: HTTP 200 OK with JSON response.*
