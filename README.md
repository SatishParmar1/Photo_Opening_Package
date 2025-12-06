# Photo Opener

A powerful, highly customizable, and easy-to-use Flutter package for viewing images and videos with beautiful UI styles, animations, and gesture support.

![Photo Opener Banner](https://via.placeholder.com/1200x600.png?text=Photo+Opener+Package)

## Features

*   **📸 Advanced Image Viewer**:
    *   Pinch-to-zoom & Double-tap zoom (powered by `photo_view`).
    *   Swipe-to-dismiss gestures (like Instagram/Facebook).
    *   Hero animation support for seamless transitions.
    *   Rotation support.
*   **🖼️ Image Gallery**:
    *   Swipeable gallery with smooth page transitions.
    *   Thumbnail strip navigation.
    *   Support for captions per image.
    *   Page indicators (1/10).
*   **🎥 Video Player**:
    *   Custom UI controls (Play/Pause, Seek, Volume, Speed).
    *   Double-tap to seek forward/backward (10s).
    *   Playback speed control (0.25x to 2.0x).
    *   Looping & Auto-play options.
*   **🎨 5 Beautiful Built-in Styles**:
    *   **Modern**: Clean, dark theme (Default).
    *   **Minimal**: Light, distraction-free UI.
    *   **Instagram**: Social media inspired look.
    *   **Cinematic**: Deep black, immersive experience.
    *   **Glassmorphism**: Trendy frosted glass effect.
*   **🛠️ Highly Customizable**:
    *   Custom builders for loading and error states.
    *   Replace default headers and footers with your own widgets.
    *   Add overlays to video players.
*   **📱 Platform Support**: Works on Android, iOS, Web, Windows, macOS, and Linux.

## Installation

Add `photo_opener_view` to your `pubspec.yaml`:

```yaml
dependencies:
  photo_opener_view: ^1.0.0
```

## Usage

### 1. Open a Single Image

```dart
import 'package:photo_opener_view/photo_opener_view.dart';

MediaViewer.openImage(
  context,
  'https://example.com/image.jpg',
  heroTag: 'my_image_hero',
  style: MediaViewerStyle.modern,
  onShare: () => print('Share clicked'),
  onDownload: () => print('Download clicked'),
);
```

### 2. Open an Image Gallery

```dart
MediaViewer.openImageGallery(
  context,
  [
    'https://example.com/image1.jpg',
    'https://example.com/image2.jpg',
    'https://example.com/image3.jpg',
  ],
  initialIndex: 0,
  captions: ['Sunset', 'Mountains', 'City Lights'],
  style: MediaViewerStyle.glassmorphism,
  showThumbnails: true,
);
```

### 3. Open a Video

```dart
MediaViewer.openVideo(
  context,
  'https://example.com/video.mp4',
  title: 'My Awesome Video',
  subtitle: 'Captured on iPhone',
  autoPlay: true,
  looping: true,
  style: MediaViewerStyle.cinematic,
);
```

## Advanced Customization

You can customize almost every aspect of the viewer to fit your app's design.

### Custom Builders & Overlays

```dart
MediaViewer.openImage(
  context,
  'https://example.com/image.jpg',
  
  // Custom loading widget
  loadingBuilder: (context) => Center(
    child: CircularProgressIndicator(color: Colors.purple),
  ),
  
  // Custom error widget
  errorBuilder: (context) => Center(
    child: Text('Oops! Could not load image.', style: TextStyle(color: Colors.white)),
  ),
  
  // Replace the top bar
  customHeader: SafeArea(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          BackButton(color: Colors.white),
          Text('My Custom Header', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
  ),
  
  // Configure zoom limits
  minScale: 0.5,
  maxScale: 10.0,
  
  // Disable immersive mode (keep status bar visible)
  immersive: false,
);
```

### Video Player Options

```dart
MediaViewer.openVideo(
  context,
  'https://example.com/video.mp4',
  
  // Start video at specific time
  startAt: Duration(seconds: 30),
  
  // Disable specific controls
  allowFullScreen: false,
  allowPlaybackSpeed: false,
  allowMuting: true,
  
  // Add an overlay (e.g., watermark)
  overlay: Positioned(
    top: 20,
    right: 20,
    child: Opacity(
      opacity: 0.5,
      child: Text('WATERMARK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  ),
);
```

## Styles

| Style | Description |
|-------|-------------|
| `MediaViewerStyle.modern` | A balanced dark theme suitable for most apps. |
| `MediaViewerStyle.minimal` | A clean, light theme that focuses purely on the content. |
| `MediaViewerStyle.instagram` | Inspired by popular social media apps, familiar to users. |
| `MediaViewerStyle.cinematic` | Deep black background, perfect for video content. |
| `MediaViewerStyle.glassmorphism` | Uses semi-transparent backgrounds with blur effects. |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Author

**Satish Parmar**

*   **GitHub**: [SatishParmar1](https://github.com/SatishParmar1)
*   **Repository**: [Photo_Opening_Package](https://github.com/SatishParmar1/Photo_Opening_Package)
*   **Other Packages**: [smart_review_prompter](https://github.com/SatishParmar1/smart_review_prompter) - A smart way to prompt users for app reviews.
