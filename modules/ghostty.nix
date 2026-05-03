{ ... }:

{
  home.file = {
    "Library/Application Support/com.mitchellh.ghostty/config".source = ../ghostty/config;

    "Library/Application Support/com.mitchellh.ghostty/shaders/cursor_tail.glsl".source =
      ../ghostty/shaders/cursor_tail.glsl;
    "Library/Application Support/com.mitchellh.ghostty/shaders/cursor_warp.glsl".source =
      ../ghostty/shaders/cursor_warp.glsl;
    "Library/Application Support/com.mitchellh.ghostty/shaders/ripple_cursor.glsl".source =
      ../ghostty/shaders/ripple_cursor.glsl;

    "Library/Application Support/com.mitchellh.ghostty/shaders/bloom.glsl".source =
      ../ghostty/shaders/bloom.glsl;
    "Library/Application Support/com.mitchellh.ghostty/shaders/starfield.glsl".source =
      ../ghostty/shaders/starfield.glsl;
  };
}
