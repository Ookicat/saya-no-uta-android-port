class GameState {
  String currentScript = "";
  int commandIndex = 0;
  String currentText = "";
  String backgroundPath = "";

  // Track foreground images: filename -> {x, y}
  Map<String, Map<String, int>> foregroundImages = {};

  String currentMusic = "";

  // Variable storage
  Map<String, int> variables = {};       // Local session (setvar)
  Map<String, int> globalVariables = {}; // Persistent (gsetvar)

  // Clear state for new script/game
  void reset() {
    currentText = "";
    backgroundPath = "";
    foregroundImages.clear();
    currentMusic = "";
  }
}