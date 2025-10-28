# N4 TV - Live Streaming App

A Flutter app for live streaming N4 TV channel content with contact information for Google Play Store compliance.

## Recent Updates

To comply with Google Play Store News policy requirements, the following changes have been made:

1. **Home Screen**: Added a home screen with navigation to watch live streams and access contact information
2. **Contact Page**: Created a dedicated "Contact Us" page with email, phone, and website information
3. **Easy Access**: Contact information is accessible from both the home screen and the live stream player via floating action buttons

## Important: Update Contact Information

**Before submitting to Google Play Store**, you must update the contact information with your actual details:

1. Open `lib/contact_page.dart`
2. Replace the placeholder email address: `contact@n4news.com` with your actual email
3. Replace the placeholder phone number: `+1-234-567-8900` with your actual phone number
4. Update the website URL if needed

### Files to Update:
- `lib/contact_page.dart` (lines 10-11 for email, lines 20-21 for phone)

## Google Play Store Requirements

This app now meets the News policy requirements:

✅ **Contact Information Page**: Easy to find contact page accessible from multiple locations in the app
✅ **Email Address**: Contact page includes email functionality
✅ **Phone Number**: Contact page includes phone dialing functionality
✅ **Website Link**: Displays your livestream website URL

## Additional Actions Required

### 1. Host the Contact Page Online

I've created a `contact.html` file for you. You need to:

1. Upload `contact.html` to your website (e.g., `https://livestream.flameinfosys.com/contact` or create a standalone page)
2. Update the contact information in `contact.html` with your actual email and phone
3. Make sure the page is publicly accessible (no login required)

### 2. Update Google Play Console

When updating your Google Play Console:

1. **Add Contact URL**: 
   - Go to Google Play Console → Your App → Store listing
   - Under "Contact details", add the URL where you hosted the contact page
   - Example: `https://livestream.flameinfosys.com/contact` or `https://flameinfosys.com/contact`
2. **Update App Declaration**: Ensure your app declaration is accurate
3. **Category Setup**: Confirm your app category is set appropriately (Entertainment or Video Players)

## Building the App

To build the app:

```bash
flutter pub get
flutter build apk --release
```

## Getting Started

This project is a Flutter application for live streaming news content.

A few resources to get you started:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/).
