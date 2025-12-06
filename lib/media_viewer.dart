// lib/media_viewer.dart
library media_viewer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';
import 'dart:async';

/// Main entry point for opening media with different viewing styles
class MediaViewer {
  /// Open a single image with hero animation and gesture controls
  static void openImage(
    BuildContext context,
    String imageUrl, {
    String? heroTag,
    bool isNetworkImage = true,
    MediaViewerStyle style = MediaViewerStyle.modern,
    Color? backgroundColor,
    bool enableSwipeToDismiss = true,
    VoidCallback? onShare,
    VoidCallback? onDownload,
    VoidCallback? onFavorite,
    WidgetBuilder? loadingBuilder,
    WidgetBuilder? errorBuilder,
    Widget? customHeader,
    Widget? customFooter,
    double minScale = 1.0,
    double maxScale = 4.0,
    bool immersive = true,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            ImageViewerScreen(
          imageUrl: imageUrl,
          heroTag: heroTag,
          isNetworkImage: isNetworkImage,
          style: style,
          backgroundColor: backgroundColor,
          enableSwipeToDismiss: enableSwipeToDismiss,
          onShare: onShare,
          onDownload: onDownload,
          onFavorite: onFavorite,
          loadingBuilder: loadingBuilder,
          errorBuilder: errorBuilder,
          customHeader: customHeader,
          customFooter: customFooter,
          minScale: minScale,
          maxScale: maxScale,
          immersive: immersive,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Open a gallery of images with swipe navigation
  static void openImageGallery(
    BuildContext context,
    List<String> imageUrls, {
    int initialIndex = 0,
    bool isNetworkImage = true,
    MediaViewerStyle style = MediaViewerStyle.modern,
    List<String>? captions,
    bool showThumbnails = true,
    VoidCallback? onShare,
    VoidCallback? onDownload,
    PageController? pageController,
    Axis scrollDirection = Axis.horizontal,
    Widget? customHeader,
    Widget? customFooter,
    ValueChanged<int>? onPageChanged,
    bool immersive = true,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            ImageGalleryScreen(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
          isNetworkImage: isNetworkImage,
          style: style,
          captions: captions,
          showThumbnails: showThumbnails,
          onShare: onShare,
          onDownload: onDownload,
          pageController: pageController,
          scrollDirection: scrollDirection,
          customHeader: customHeader,
          customFooter: customFooter,
          onPageChanged: onPageChanged,
          immersive: immersive,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Open a video with custom controls
  static void openVideo(
    BuildContext context,
    String videoUrl, {
    bool isNetworkVideo = true,
    MediaViewerStyle style = MediaViewerStyle.modern,
    String? title,
    String? subtitle,
    bool autoPlay = true,
    bool looping = false,
    VoidCallback? onShare,
    bool showControls = true,
    bool allowFullScreen = true,
    bool allowPlaybackSpeed = true,
    bool allowMuting = true,
    Duration? startAt,
    Widget? overlay,
    bool immersive = true,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            VideoViewerScreen(
          videoUrl: videoUrl,
          isNetworkVideo: isNetworkVideo,
          style: style,
          title: title,
          subtitle: subtitle,
          autoPlay: autoPlay,
          looping: looping,
          onShare: onShare,
          showControls: showControls,
          allowFullScreen: allowFullScreen,
          allowPlaybackSpeed: allowPlaybackSpeed,
          allowMuting: allowMuting,
          startAt: startAt,
          overlay: overlay,
          immersive: immersive,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

/// Different viewing styles
enum MediaViewerStyle {
  modern,
  minimal,
  instagram,
  cinematic,
  glassmorphism,
}

/// Single Image Viewer with zoom, pan, and swipe to dismiss
class ImageViewerScreen extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;
  final bool isNetworkImage;
  final MediaViewerStyle style;
  final Color? backgroundColor;
  final bool enableSwipeToDismiss;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final VoidCallback? onFavorite;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;
  final Widget? customHeader;
  final Widget? customFooter;
  final double minScale;
  final double maxScale;
  final bool immersive;

  const ImageViewerScreen({
    Key? key,
    required this.imageUrl,
    this.heroTag,
    this.isNetworkImage = true,
    this.style = MediaViewerStyle.modern,
    this.backgroundColor,
    this.enableSwipeToDismiss = true,
    this.onShare,
    this.onDownload,
    this.onFavorite,
    this.loadingBuilder,
    this.errorBuilder,
    this.customHeader,
    this.customFooter,
    this.minScale = 1.0,
    this.maxScale = 4.0,
    this.immersive = true,
  }) : super(key: key);

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  bool _showControls = true;
  double _dragOffset = 0;
  double _dragScale = 1.0;
  bool _isDragging = false;
  bool _isFavorite = false;
  Timer? _hideControlsTimer;
  PhotoViewController? _photoViewController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
    _photoViewController = PhotoViewController();
    if (widget.immersive) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _hideControlsTimer?.cancel();
    _photoViewController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _onVerticalDragStart(DragStartDetails details) {
    if (!widget.enableSwipeToDismiss) return;
    setState(() {
      _isDragging = true;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!widget.enableSwipeToDismiss) return;
    setState(() {
      _dragOffset += details.delta.dy;
      _dragScale = 1.0 - (_dragOffset.abs() / 1000).clamp(0.0, 0.3);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!widget.enableSwipeToDismiss) return;
    if (_dragOffset.abs() > 100) {
      Navigator.pop(context);
    } else {
      setState(() {
        _dragOffset = 0;
        _dragScale = 1.0;
        _isDragging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Dimmed background
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: (widget.backgroundColor ?? _getBackgroundColor())
                    .withOpacity(_isDragging ? 0.5 : 0.95),
              ),
            ),
            // Image with gestures
            GestureDetector(
              onTap: _toggleControls,
              onVerticalDragStart: _onVerticalDragStart,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, _dragOffset),
                  child: Transform.scale(
                    scale: _dragScale,
                    child: widget.heroTag != null
                        ? Hero(
                            tag: widget.heroTag!,
                            child: _buildPhotoView(),
                          )
                        : _buildPhotoView(),
                  ),
                ),
              ),
            ),
            // Controls overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: _buildControls(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoView() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: PhotoView(
        controller: _photoViewController,
        imageProvider: widget.isNetworkImage
            ? CachedNetworkImageProvider(widget.imageUrl)
            : FileImage(File(widget.imageUrl)) as ImageProvider,
        minScale: PhotoViewComputedScale.contained * widget.minScale,
        maxScale: PhotoViewComputedScale.covered * widget.maxScale,
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        loadingBuilder: (context, event) => widget.loadingBuilder != null
            ? widget.loadingBuilder!(context)
            : _buildLoadingIndicator(event),
        errorBuilder: (context, error, stackTrace) =>
            widget.errorBuilder != null
                ? widget.errorBuilder!(context)
                : _buildErrorWidget(),
        enableRotation: true,
        gaplessPlayback: true,
      ),
    );
  }

  Widget _buildLoadingIndicator(ImageChunkEvent? event) {
    final progress = event?.expectedTotalBytes != null
        ? event!.cumulativeBytesLoaded / event.expectedTotalBytes!
        : null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.style == MediaViewerStyle.glassmorphism)
            _buildGlassmorphicLoader(progress)
          else
            _buildModernLoader(progress),
        ],
      ),
    );
  }

  Widget _buildModernLoader(double? progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        if (progress != null)
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildGlassmorphicLoader(double? progress) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Center(
        child: _buildModernLoader(progress),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image_outlined, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Failed to load image',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh, color: Colors.white70),
            label: const Text('Retry', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: _buildControlsDecoration(),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.customHeader ?? _buildTopBar(),
            widget.customFooter ?? _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildControlsDecoration() {
    switch (widget.style) {
      case MediaViewerStyle.glassmorphism:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.5),
            ],
            stops: const [0.0, 0.15, 0.85, 1.0],
          ),
        );
      case MediaViewerStyle.cinematic:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
            stops: const [0.0, 0.2, 0.8, 1.0],
          ),
        );
      default:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.6),
            ],
            stops: const [0.0, 0.15, 0.85, 1.0],
          ),
        );
    }
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(
            icon: Icons.close,
            onPressed: () => Navigator.pop(context),
            tooltip: 'Close',
          ),
          Row(
            children: [
              if (widget.onFavorite != null)
                _buildIconButton(
                  icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                  onPressed: () {
                    setState(() => _isFavorite = !_isFavorite);
                    widget.onFavorite?.call();
                  },
                  tooltip: 'Favorite',
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
              if (widget.onDownload != null)
                _buildIconButton(
                  icon: Icons.download_outlined,
                  onPressed: widget.onDownload,
                  tooltip: 'Download',
                ),
              if (widget.onShare != null)
                _buildIconButton(
                  icon: Icons.share_outlined,
                  onPressed: widget.onShare,
                  tooltip: 'Share',
                ),
              _buildMoreOptionsButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    Color color = Colors.white,
  }) {
    return widget.style == MediaViewerStyle.glassmorphism
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: Icon(icon, color: color, size: 24),
              onPressed: onPressed,
              tooltip: tooltip,
            ),
          )
        : IconButton(
            icon: Icon(icon, color: color, size: 26),
            onPressed: onPressed,
            tooltip: tooltip,
          );
  }

  Widget _buildMoreOptionsButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white, size: 26),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'info',
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white70, size: 20),
              SizedBox(width: 12),
              Text('Image Info', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'rotate',
          child: Row(
            children: [
              Icon(Icons.rotate_right, color: Colors.white70, size: 20),
              SizedBox(width: 12),
              Text('Rotate', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'wallpaper',
          child: Row(
            children: [
              Icon(Icons.wallpaper, color: Colors.white70, size: 20),
              SizedBox(width: 12),
              Text('Set as Wallpaper', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        // Handle menu actions
      },
    );
  }

  Widget _buildBottomBar() {
    if (widget.style == MediaViewerStyle.minimal) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildZoomIndicator(),
        ],
      ),
    );
  }

  Widget _buildZoomIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.style == MediaViewerStyle.glassmorphism
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: widget.style == MediaViewerStyle.glassmorphism
            ? Border.all(color: Colors.white.withOpacity(0.2))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.zoom_in, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          const Text(
            'Double tap to zoom',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.style) {
      case MediaViewerStyle.minimal:
        return Colors.white;
      case MediaViewerStyle.cinematic:
        return Colors.black;
      case MediaViewerStyle.glassmorphism:
        return const Color(0xFF1a1a2e);
      default:
        return Colors.black87;
    }
  }
}

/// Image Gallery with PageView and PhotoViewGallery
class ImageGalleryScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final bool isNetworkImage;
  final MediaViewerStyle style;
  final List<String>? captions;
  final bool showThumbnails;
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final PageController? pageController;
  final Axis scrollDirection;
  final Widget? customHeader;
  final Widget? customFooter;
  final ValueChanged<int>? onPageChanged;
  final bool immersive;

  const ImageGalleryScreen({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.isNetworkImage = true,
    this.style = MediaViewerStyle.modern,
    this.captions,
    this.showThumbnails = true,
    this.onShare,
    this.onDownload,
    this.pageController,
    this.scrollDirection = Axis.horizontal,
    this.customHeader,
    this.customFooter,
    this.onPageChanged,
    this.immersive = true,
  }) : super(key: key);

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late PageController _thumbnailController;
  late AnimationController _fadeController;
  late int _currentIndex;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = widget.pageController ??
        PageController(initialPage: widget.initialIndex);
    _thumbnailController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 0.15,
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeController.forward();
    if (widget.immersive) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbnailController.dispose();
    _fadeController.dispose();
    _hideControlsTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onPageChanged?.call(index);
    _thumbnailController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo gallery
          PhotoViewGallery.builder(
            scrollDirection: widget.scrollDirection,
            pageController: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.imageUrls.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: widget.isNetworkImage
                    ? CachedNetworkImageProvider(widget.imageUrls[index])
                    : FileImage(File(widget.imageUrls[index])) as ImageProvider,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
                heroAttributes: PhotoViewHeroAttributes(tag: 'gallery_$index'),
                errorBuilder: (context, error, stackTrace) =>
                    _buildErrorWidget(),
              );
            },
            loadingBuilder: (context, event) => _buildLoadingWidget(event),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            scrollPhysics: const BouncingScrollPhysics(),
          ),
          // Tap to toggle controls
          GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
              if (_showControls) {
                _startHideControlsTimer();
              }
            },
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
          // Controls overlay
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !_showControls,
              child: _buildControls(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(ImageChunkEvent? event) {
    final progress = event?.expectedTotalBytes != null
        ? event!.cumulativeBytesLoaded / event.expectedTotalBytes!
        : null;

    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[600]!,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: progress != null
                ? Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  )
                : const Icon(
                    Icons.image,
                    size: 48,
                    color: Colors.white24,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image, color: Colors.white54, size: 64),
          SizedBox(height: 16),
          Text(
            'Failed to load image',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
          stops: const [0.0, 0.15, 0.75, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.customHeader ?? _buildTopBar(),
            widget.customFooter ??
                Column(
                  children: [
                    if (widget.captions != null &&
                        _currentIndex < widget.captions!.length)
                      _buildCaption(),
                    if (widget.showThumbnails) _buildThumbnails(),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          _buildPageIndicator(),
          Row(
            children: [
              if (widget.onDownload != null)
                IconButton(
                  icon: const Icon(Icons.download_outlined,
                      color: Colors.white, size: 24),
                  onPressed: widget.onDownload,
                ),
              if (widget.onShare != null)
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 24),
                  onPressed: widget.onShare,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${_currentIndex + 1} / ${widget.imageUrls.length}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCaption() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(
        widget.captions![_currentIndex],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildThumbnails() {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        controller: _thumbnailController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.imageUrls.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: widget.isNetworkImage
                      ? CachedNetworkImage(
                          imageUrl: widget.imageUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[800],
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error, color: Colors.white54),
                        )
                      : Image.file(
                          File(widget.imageUrls[index]),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Video Viewer with custom controls
class VideoViewerScreen extends StatefulWidget {
  final String videoUrl;
  final bool isNetworkVideo;
  final MediaViewerStyle style;
  final String? title;
  final String? subtitle;
  final bool autoPlay;
  final bool looping;
  final VoidCallback? onShare;
  final bool showControls;
  final bool allowFullScreen;
  final bool allowPlaybackSpeed;
  final bool allowMuting;
  final Duration? startAt;
  final Widget? overlay;
  final bool immersive;

  const VideoViewerScreen({
    Key? key,
    required this.videoUrl,
    this.isNetworkVideo = true,
    this.style = MediaViewerStyle.modern,
    this.title,
    this.subtitle,
    this.autoPlay = true,
    this.looping = false,
    this.onShare,
    this.showControls = true,
    this.allowFullScreen = true,
    this.allowPlaybackSpeed = true,
    this.allowMuting = true,
    this.startAt,
    this.overlay,
    this.immersive = true,
  }) : super(key: key);

  @override
  State<VideoViewerScreen> createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<VideoViewerScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _playPauseController;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _hasError = false;
  Timer? _hideControlsTimer;
  double _currentVolume = 1.0;
  double _playbackSpeed = 1.0;
  bool _isMuted = false;

  final List<double> _playbackSpeeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _showControls = widget.showControls;
    _playPauseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initializeVideo();
    if (widget.immersive) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _startHideControlsTimer();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = widget.isNetworkVideo
          ? VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          : VideoPlayerController.file(File(widget.videoUrl));

      await _controller.initialize();
      _controller.setLooping(widget.looping);
      if (widget.startAt != null) {
        await _controller.seekTo(widget.startAt!);
      }

      _controller.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
            _isBuffering = _controller.value.isBuffering;
          });

          if (_isPlaying) {
            _playPauseController.forward();
          } else {
            _playPauseController.reverse();
          }
        }
      });

      setState(() {
        _isInitialized = true;
      });

      if (widget.autoPlay) {
        _controller.play();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _playPauseController.dispose();
    _hideControlsTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (_isPlaying) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _showControls && _isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
      _startHideControlsTimer();
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : _currentVolume);
    });
  }

  void _seekForward() {
    final current = _controller.value.position;
    final target = current + const Duration(seconds: 10);
    if (target < _controller.value.duration) {
      _controller.seekTo(target);
    } else {
      _controller.seekTo(_controller.value.duration);
    }
  }

  void _seekBackward() {
    final current = _controller.value.position;
    final target = current - const Duration(seconds: 10);
    if (target > Duration.zero) {
      _controller.seekTo(target);
    } else {
      _controller.seekTo(Duration.zero);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _hasError
          ? _buildErrorWidget()
          : !_isInitialized
              ? _buildLoadingWidget()
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      _showControls = !_showControls;
                    });
                    if (_showControls) {
                      _startHideControlsTimer();
                    }
                  },
                  onDoubleTapDown: (details) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    if (details.localPosition.dx < screenWidth / 2) {
                      _seekBackward();
                    } else {
                      _seekForward();
                    }
                  },
                  child: Stack(
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                      if (widget.overlay != null) widget.overlay!,
                      if (_isBuffering) _buildBufferingIndicator(),
                      AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: IgnorePointer(
                          ignoring: !_showControls,
                          child: _buildControls(),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Loading video...',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Failed to load video',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
              });
              _initializeVideo();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  Widget _buildBufferingIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
          stops: const [0.0, 0.25, 0.65, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTopBar(),
            _buildCenterControls(),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          if (widget.title != null)
            Expanded(
              child: Column(
                children: [
                  Text(
                    widget.title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          Row(
            children: [
              if (widget.onShare != null)
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 24),
                  onPressed: widget.onShare,
                ),
              _buildMoreOptionsButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoreOptionsButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.speed, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Text(
                'Playback Speed (${_playbackSpeed}x)',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () => _showPlaybackSpeedDialog());
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                widget.looping ? Icons.repeat_one : Icons.repeat,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                _controller.value.isLooping ? 'Loop: On' : 'Loop: Off',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          onTap: () {
            _controller.setLooping(!_controller.value.isLooping);
          },
        ),
      ],
    );
  }

  void _showPlaybackSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Playback Speed',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _playbackSpeeds.map((speed) {
            return ListTile(
              title: Text(
                '${speed}x',
                style: TextStyle(
                  color: speed == _playbackSpeed
                      ? Colors.blue
                      : Colors.white,
                  fontWeight: speed == _playbackSpeed
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              trailing: speed == _playbackSpeed
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                setState(() {
                  _playbackSpeed = speed;
                  _controller.setPlaybackSpeed(speed);
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.replay_10,
          onPressed: _seekBackward,
          size: 48,
        ),
        const SizedBox(width: 40),
        _buildPlayPauseButton(),
        const SizedBox(width: 40),
        _buildControlButton(
          icon: Icons.forward_10,
          onPressed: _seekForward,
          size: 48,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 40,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        iconSize: size,
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _playPauseController,
          color: Colors.black,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                _formatDuration(_controller.value.position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: _controller.value.position.inMilliseconds
                        .toDouble()
                        .clamp(
                          0,
                          _controller.value.duration.inMilliseconds.toDouble(),
                        ),
                    min: 0,
                    max: _controller.value.duration.inMilliseconds.toDouble(),
                    activeColor: Colors.white,
                    inactiveColor: Colors.white.withOpacity(0.3),
                    onChanged: (value) {
                      _controller.seekTo(Duration(milliseconds: value.toInt()));
                    },
                    onChangeStart: (_) {
                      _hideControlsTimer?.cancel();
                    },
                    onChangeEnd: (_) {
                      _startHideControlsTimer();
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(_controller.value.duration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
        // Bottom controls row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (widget.allowMuting)
                    IconButton(
                      icon: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                      onPressed: _toggleMute,
                    ),
                  if (widget.allowMuting)
                    SizedBox(
                      width: 100,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 5),
                          trackHeight: 2,
                        ),
                        child: Slider(
                          value: _isMuted ? 0.0 : _currentVolume,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white.withOpacity(0.3),
                          onChanged: (value) {
                            setState(() {
                              _currentVolume = value;
                              _isMuted = value == 0;
                              _controller.setVolume(value);
                            });
                          },
                        ),
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  if (widget.allowPlaybackSpeed)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${_playbackSpeed}x',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  if (widget.allowFullScreen)
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                      onPressed: () {
                        if (MediaQuery.of(context).orientation ==
                            Orientation.portrait) {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.landscapeRight,
                          ]);
                        } else {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                          ]);
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
