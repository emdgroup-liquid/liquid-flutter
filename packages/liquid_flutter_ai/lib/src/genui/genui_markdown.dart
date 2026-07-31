/// Strips ```genui fenced blocks from markdown for display.
String ldStripGenuiBlocks(String content) {
  return content.replaceAll(RegExp(r'```genui\s*\n[\s\S]*?(?:```|$)'), '').trim();
}
