import 'package:flutter/material.dart';
import 'package:photo_opener_view/photo_opener_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Opener Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  // Sample images from Unsplash
  static const List<String> sampleImages = [
    'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=800',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800',
    'https://images.unsplash.com/photo-1426604966848-d7adac402bff?w=800',
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800',
    'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=800',
  ];

  // Sample video
  static const String sampleVideo =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Opener Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Single Image Section
            _buildSectionTitle('Single Image Viewer'),
            const SizedBox(height: 8),
            _buildImageGrid(context),
            const SizedBox(height: 24),

            // Gallery Section
            _buildSectionTitle('Image Gallery'),
            const SizedBox(height: 8),
            _buildGalleryButton(context),
            const SizedBox(height: 24),

            // Video Section
            _buildSectionTitle('Video Player'),
            const SizedBox(height: 8),
            _buildVideoButton(context),
            const SizedBox(height: 24),

            // Style Options Section
            _buildSectionTitle('Different Styles'),
            const SizedBox(height: 8),
            _buildStyleButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sampleImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              MediaViewer.openImage(
                context,
                sampleImages[index],
                heroTag: 'image_$index',
                style: MediaViewerStyle.modern,
                onShare: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share clicked!')),
                  );
                },
                onDownload: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Download clicked!')),
                  );
                },
                onFavorite: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Favorite toggled!')),
                  );
                },
              );
            },
            child: Hero(
              tag: 'image_$index',
              child: Container(
                width: 120,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    sampleImages[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGalleryButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
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
          onShare: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share gallery image!')),
            );
          },
        );
      },
      icon: const Icon(Icons.photo_library),
      label: const Text('Open Gallery (5 images)'),
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
    );
  }

  Widget _buildVideoButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        MediaViewer.openVideo(
          context,
          sampleVideo,
          title: 'Butterfly Video',
          subtitle: 'Nature documentary',
          autoPlay: true,
          looping: true,
          onShare: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Share video!')));
          },
        );
      },
      icon: const Icon(Icons.play_circle),
      label: const Text('Play Sample Video'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.red[400],
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStyleButtons(BuildContext context) {
    final styles = [
      ('Modern', MediaViewerStyle.modern, Colors.blue),
      ('Minimal', MediaViewerStyle.minimal, Colors.grey),
      ('Instagram', MediaViewerStyle.instagram, Colors.pink),
      ('Cinematic', MediaViewerStyle.cinematic, Colors.black87),
      ('Glass', MediaViewerStyle.glassmorphism, Colors.purple),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: styles.map((style) {
        return ElevatedButton(
          onPressed: () {
            MediaViewer.openImage(context, sampleImages[0], style: style.$2);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: style.$3,
            foregroundColor: Colors.white,
          ),
          child: Text(style.$1),
        );
      }).toList(),
    );
  }
}
