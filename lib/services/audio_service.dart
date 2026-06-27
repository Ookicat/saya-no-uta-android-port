import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _soundPlayer = AudioPlayer();

  AudioService() {
    // Set BGM to loop by default
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  /// Plays background music. Use '~' to stop.
  Future<void> playMusic(String path) async {
    if (path == '~') {
      await _musicPlayer.stop();
      return;
    }

    await _musicPlayer.stop();
    // AssetSource automatically looks in the 'assets/' folder
    await _musicPlayer.play(AssetSource('sound/$path'));
  }

  /// Plays a sound effect or voice line.
  /// 'type' can be used to handle looping SFX if needed.
  Future<void> playSound(String path, String type) async {
    if (path == '~') {
      await _soundPlayer.stop();
      return;
    }

    await _soundPlayer.stop();

    // -1 indicates a looping ambient sound
    if (type == "-1") {
      await _soundPlayer.setReleaseMode(ReleaseMode.loop);
    } else {
      await _soundPlayer.setReleaseMode(ReleaseMode.release);
    }

    await _soundPlayer.play(AssetSource('sound/$path'));
  }

  void dispose() {
    _musicPlayer.dispose();
    _soundPlayer.dispose();
  }
}