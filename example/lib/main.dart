import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_opener_view/photo_opener_view.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Experience',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: const ColorScheme.dark(
          primary: Colors.amber,
          secondary: Colors.deepPurpleAccent,
          surface: Color(0xFF1E1E1E),
        ),
        textTheme: const TextTheme(
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ),
      home: const ModernDemoScreen(),
    );
  }
}

class ModernDemoScreen extends StatelessWidget {
  const ModernDemoScreen({super.key});

  static const List<String> sampleImages = [
    'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=800',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800',
    'https://images.unsplash.com/photo-1426604966848-d7adac402bff?w=800',
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800',
    'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=800',
  ];

  static const String sampleVideo =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    "Recent Stories",
                    Icons.history_edu,
                  ),
                  const SizedBox(height: 16),
                  _buildHorizontalStories(context),

                  const SizedBox(height: 40),
                  _buildSectionHeader(
                    context,
                    "Featured Cinema",
                    Icons.movie_filter,
                  ),
                  const SizedBox(height: 16),
                  _buildFeaturedVideo(context), // Your complex container

                  const SizedBox(height: 24),
                  _buildQuickPlayCard(context), // Your simple video button

                  const SizedBox(height: 40),
                  _buildSectionHeader(
                    context,
                    "Collections",
                    Icons.photo_library,
                  ),
                  const SizedBox(height: 16),
                  _buildGalleryCard(context),

                  const SizedBox(height: 40),
                  _buildSectionHeader(context, "View Styles", Icons.palette),
                  const SizedBox(height: 16),
                  _buildStyleGrid(context),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. AESTHETIC APP BAR
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0F0F0F),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          "Media Showcase",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            letterSpacing: 1.2,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(sampleImages[0], fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3), // FIXED
                    const Color(0xFF0F0F0F),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. STORIES SECTION (Single Image Viewer)
  Widget _buildHorizontalStories(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: sampleImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _openImage(context, index),
              child: Hero(
                tag: 'image_$index',
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(sampleImages[index]),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5), // FIXED
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.fullscreen, color: Colors.white70),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 3. FEATURED VIDEO
  Widget _buildFeaturedVideo(BuildContext context) {
    return VideoThumbnailContainer(
      // 1. DATA SOURCES
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1559257602-5377dc76a524',
      isNetworkVideo: true,

      // 2. INITIAL STATE
      showThumbnail: true,
      enableMute: false,
      playbackSpeed: 1.5,

      // 3. BEHAVIOR
      enableLoop: true,
      showControls: true,
      showProgressBar: true,

      // 4. DIMENSIONS & STYLING
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.5), // FIXED
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.15), // FIXED
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),

      // 5. METADATA
      title: "Golden Bee",
      subtitle: "Captured in 4K resolution",

      // 6. CUSTOM PLAY BUTTON THEME
      playButtonTheme: const PlayButtonTheme(
        style: PlayButtonStyle.gradient,
        size: 80,
        iconSize: 50,
        gradientColors: [Colors.amber, Colors.orange],
        iconColor: Colors.white,
        elevation: 10,
        opacity: 0.9,
      ),

      // 7. CALLBACKS
      onVideoStart: () => debugPrint("Analytics: Video Started"),
      onVideoEnd: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Video Finished!")));
      },
    );
  }

  // 4. SIMPLE VIDEO CARD
  Widget _buildQuickPlayCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.2), // FIXED
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.redAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Quick Play",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Nature Documentary",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), // FIXED
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              MediaViewer.openVideo(
                context,
                sampleVideo,
                title: 'Butterfly Lifecycle',
                subtitle: 'Nature Documentary Series',
                autoPlay: true,
                looping: true,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: const StadiumBorder(),
            ),
            child: const Text("Watch"),
          ),
        ],
      ),
    );
  }

  // 5. GALLERY CARD
  Widget _buildGalleryCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        MediaViewer.openImageGallery(
          context,
          sampleImages,
          initialIndex: 0,
          captions: [
            'Beautiful sunset over the ocean',
            'Mountain landscape at dawn',
            'Peaceful forest trail',
            'Misty morning in the valley',
            'Ancient woodland path',
          ],
          showThumbnails: true,
        );
      },
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: NetworkImage(sampleImages[2]),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.6), // FIXED
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30),
              borderRadius: BorderRadius.circular(30),
              color: Colors.white.withValues(alpha: 0.1), // FIXED
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.grid_view, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Open Gallery (5 Items)",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 6. STYLE GRID
  Widget _buildStyleGrid(BuildContext context) {
    final styles = [
      ('Modern', MediaViewerStyle.modern, Colors.blueAccent),
      ('Minimal', MediaViewerStyle.minimal, Colors.grey),
      ('Social', MediaViewerStyle.instagram, Colors.purpleAccent),
      ('Cinema', MediaViewerStyle.cinematic, Colors.redAccent),
      ('Glass', MediaViewerStyle.glassmorphism, Colors.tealAccent),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: styles.map((item) {
        return ActionChip(
          label: Text(item.$1),
          avatar: Icon(Icons.circle, color: item.$3, size: 12),
          backgroundColor: const Color(0xFF252525),
          labelStyle: const TextStyle(color: Colors.white70),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onPressed: () {
            MediaViewer.openImage(context, sampleImages[0], style: item.$2);
          },
        );
      }).toList(),
    );
  }

  // HELPER: Section Titles
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  // HELPER: Open Logic
  void _openImage(BuildContext context, int index) {
    MediaViewer.openImage(
      context,
      sampleImages[index],
      heroTag: 'image_$index',
      style: MediaViewerStyle.modern,
      onShare: () => _showSnack(context, 'Shared image!'),
      onDownload: () => _showSnack(context, 'Downloaded!'),
      onFavorite: () => _showSnack(context, 'Added to favorites'),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
