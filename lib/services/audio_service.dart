import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _soundPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();

  AudioService() {
    _initAudioContext();
  }

  /// Configures the native OS to allow multiple sounds at once
  Future<void> _initAudioContext() async {
    await AudioPlayer.global.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        // CRITICAL: Tells Android not to pause music when a voice line plays
        audioFocus: AndroidAudioFocus.none,
        audioMode: AndroidAudioMode.normal,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
      ),
    ));

    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playMusic(String path) async {
    if (path == '~') {
      await _musicPlayer.stop();
      return;
    }

    await _musicPlayer.stop();
    await Future.delayed(const Duration(milliseconds: 50));
    await _musicPlayer.play(AssetSource('sound/$path'));
  }

  Future<void> playSound(String path, String type) async {
    if (path == '~') {
      await _soundPlayer.stop();
      await _voicePlayer.stop();
      return;
    }

    // Using .contains is slightly safer than .startsWith just in case
    // the parser accidentally leaves a leading space or slash!
    if (path.contains('voice/')) {
      await _voicePlayer.stop();
      await _voicePlayer.setReleaseMode(ReleaseMode.release);
      await _voicePlayer.play(AssetSource('sound/$path'));
    } else {
      await _soundPlayer.stop();
      if (type == "-1") {
        await _soundPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        await _soundPlayer.setReleaseMode(ReleaseMode.release);
      }
      await _soundPlayer.play(AssetSource('sound/$path'));
    }
  }

  Future<void> stopVoice() async {
    await _voicePlayer.stop();
  }

  void dispose() {
    _musicPlayer.dispose();
    _soundPlayer.dispose();
    _voicePlayer.dispose();
  }
}