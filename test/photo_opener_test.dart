import 'package:flutter_test/flutter_test.dart';

import 'package:photo_opener_view/photo_opener_view.dart';

void main() {
  test('MediaViewerStyle enum has all values', () {
    expect(MediaViewerStyle.values.length, 5);
    expect(MediaViewerStyle.modern, isNotNull);
    expect(MediaViewerStyle.minimal, isNotNull);
    expect(MediaViewerStyle.instagram, isNotNull);
    expect(MediaViewerStyle.cinematic, isNotNull);
    expect(MediaViewerStyle.glassmorphism, isNotNull);
  });
}
