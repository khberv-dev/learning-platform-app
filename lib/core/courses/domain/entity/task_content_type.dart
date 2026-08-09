/// How a task's attached content should be presented.
///
/// [audio] and [picture] come from an upload, so the task's `file` holds a CDN
/// path. [text] is set when the content was written inline, so `file` holds the
/// passage itself rather than a URL.
enum TaskContentType {
  audio,
  text,
  picture;

  static TaskContentType? fromJson(String? raw) => switch (raw) {
    'audio' => TaskContentType.audio,
    'text' => TaskContentType.text,
    'picture' => TaskContentType.picture,
    _ => null,
  };
}
