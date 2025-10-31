# Android TV Banner Verification Guide

## Banner Requirements

- **Dimensions**: 320x180 pixels at `xhdpi` density
- **Format**: PNG (recommended) or JPG
- **Background**: Fully opaque (no transparency)
- **Content**: Should include app name "N4 TV" for identification
- **Aspect Ratio**: 16:9 (320:180)

## Where to Verify Banner Requirements

### 1. **Google Play Console** (During App Upload)
   - When uploading your APK/AAB to Google Play Console
   - Go to: **Store presence → Store listing → Graphics**
   - The console will validate that your TV banner meets requirements
   - Errors will show if dimensions don't match

### 2. **Android Studio Preview**
   - Open `android/app/src/main/res/drawable-xhdpi/` (create if needed)
   - Right-click on banner image → Preview
   - Check dimensions in the preview window

### 3. **Testing on Android TV Device/Emulator**
   - Install the app on an Android TV
   - Check the home screen/app launcher
   - The banner should display correctly (320x180dp effective size)
   - Banner appears in the row of apps on TV home screen

### 4. **Command Line Verification** (for PNG images)
   ```bash
   # Check image dimensions
   file android/app/src/main/res/drawable-xhdpi/tv_banner.png
   # Or use ImageMagick if installed
   identify android/app/src/main/res/drawable-xhdpi/tv_banner.png
   ```

## Current Setup

Currently using an XML drawable (`tv_banner.xml`) that references the app icon. This works but for best results, you should:

1. **Create a dedicated banner image** (320x180px at xhdpi)
2. **Place it in**: `android/app/src/main/res/drawable-xhdpi/tv_banner.png`
3. **Or use multiple densities**:
   - `drawable-mdpi/`: 320x180px
   - `drawable-hdpi/`: 480x270px  
   - `drawable-xhdpi/`: 640x360px (REQUIRED)
   - `drawable-xxhdpi/`: 960x540px
   - `drawable-xxxhdpi/`: 1280x720px

## Creating Your Banner

Use any image editor (Photoshop, GIMP, Figma, etc.) to create:
- Canvas size: 320x180px (or 640x360px for xhdpi)
- Include "N4 TV" text prominently
- Use your app branding/colors
- Export as PNG with opaque background

## Verification Checklist

- [ ] Banner is exactly 320x180dp (or proper density-scaled sizes)
- [ ] Image is fully opaque (no transparency)
- [ ] App name "N4 TV" is visible
- [ ] Banner referenced in AndroidManifest.xml (`android:banner="@drawable/tv_banner"`)
- [ ] Banner displays correctly on Android TV emulator/device
- [ ] No errors in Google Play Console during upload

