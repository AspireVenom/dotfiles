{
  "manifest_version": 3,
  "name": "Omarchy Theme",
  "version": "1.0",
  "description": "Rendered from the active Omarchy theme (~/.config/omarchy/themed/chromium-manifest.json.tpl). Published for opt-in themes by hooks/theme-set.d/20-chromium.",
  "theme": {
    "colors": {
      "frame": [{{ background_rgb }}],
      "frame_inactive": [{{ background_rgb }}],
      "frame_incognito": [{{ selection_background_rgb }}],
      "frame_incognito_inactive": [{{ selection_background_rgb }}],
      "background_tab": [{{ color0_rgb }}],
      "background_tab_inactive": [{{ color0_rgb }}],
      "background_tab_incognito": [{{ selection_background_rgb }}],
      "background_tab_incognito_inactive": [{{ selection_background_rgb }}],
      "toolbar": [{{ background_rgb }}],
      "toolbar_text": [{{ foreground_rgb }}],
      "toolbar_button_icon": [{{ accent_rgb }}],
      "tab_text": [{{ foreground_rgb }}],
      "tab_background_text": [{{ color8_rgb }}],
      "tab_background_text_inactive": [{{ color8_rgb }}],
      "bookmark_text": [{{ foreground_rgb }}],
      "omnibox_background": [{{ color0_rgb }}],
      "omnibox_text": [{{ foreground_rgb }}],
      "ntp_background": [{{ background_rgb }}],
      "ntp_text": [{{ foreground_rgb }}],
      "ntp_link": [{{ accent_rgb }}],
      "ntp_header": [{{ accent_rgb }}]
    }
  }
}
