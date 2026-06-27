class AssetService {
  /// Resolves background image paths.
  /// Handles both direct files (bp01me0.jpg) and subfolders (cg/03_1.jpg).
  static String getBackgroundPath(String filename) {
    return 'assets/background/$filename';
  }

  /// Resolves character sprite paths.
  static String getForegroundPath(String filename) {
    return 'assets/foreground/$filename';
  }

  /// Resolves audio paths (BGM and SFX/Voice).
  static String getAudioPath(String path) {
    return 'assets/sound/$path';
  }
}