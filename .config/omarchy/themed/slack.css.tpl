/* Slack theme rendered from the active Omarchy theme (~/.config/omarchy/themed/slack.css.tpl).
   Injected as a user-origin stylesheet by the loader that slack-omarchy-build adds to
   ~/.local/opt/slack-omarchy, so `!important` here outranks Slack's own `!important` rules.
   Replaces the hand-patched DOUG_SLACK_OLED_BLACK V2/V3 bundles (no observers, no timers). */

:root,
body,
.sk-client-theme--dark {
  /* Slack's theme variables take bare "r, g, b" triplets */
  --sk_primary_background: {{ background_rgb }} !important;
  --sk_primary_foreground: {{ foreground_rgb }} !important;
  --sk_foreground_max: {{ foreground_rgb }} !important;
  --sk_foreground_high: {{ foreground_rgb }} !important;
  --sk_foreground_low: {{ color8_rgb }} !important;
  --sk_foreground_min: {{ color8_rgb }} !important;
  --sk_foreground_min_solid: {{ color0_rgb }} !important;
  --sk_foreground_low_solid: {{ color0_rgb }} !important;
  --sk_foreground_high_solid: {{ foreground_rgb }} !important;
  --sk_foreground_max_solid: {{ foreground_rgb }} !important;

  --omarchy-bg: rgb({{ background_rgb }});
  --omarchy-raised: rgb({{ color0_rgb }});
  --omarchy-hover: rgba({{ foreground_rgb }}, 0.05);
  --omarchy-border: rgba({{ foreground_rgb }}, 0.10);
  --omarchy-text: rgb({{ foreground_rgb }});
  --omarchy-muted: rgb({{ color8_rgb }});
  --omarchy-accent: rgb({{ accent_rgb }});
  --omarchy-accent-soft: rgba({{ accent_rgb }}, 0.16);
  --omarchy-ember: {{ selection_background }};
}

/* ---------- Type ---------- */

body,
.c-message_kit__text,
.c-message__body,
.c-message_kit__sender,
.c-message_kit__username,
.c-message_kit__timestamp,
.c-timestamp,
.p-channel_header__channel_title,
.p-view_header__title,
.p-channel_sidebar,
.p-ia4_sidebar,
.p-ia4_top_nav,
.p-top_nav,
.p-message_input,
.ql-editor,
.c-texty_input,
input,
textarea {
  font-family: "Monaspace Radon Var", "Monaspace Radon", ui-monospace, "JetBrainsMono Nerd Font", monospace !important;
  font-variant-ligatures: contextual common-ligatures !important;
}

/* ---------- Surfaces ---------- */

html,
body,
.p-client_workspace,
.p-client_container,
.p-workspace,
.p-workspace__primary_view,
.p-workspace__secondary_view,
.p-view_contents,
.p-message_pane,
.p-message_pane__foreground,
.p-message_pane__messages,
.c-virtual_list,
.c-virtual_list__scroll_container,
.c-scrollbar__hider,
.p-ia4_client,
.p-ia4_client__workspace,
.p-ia4_client__body,
.p-ia4_page_contents,
.p-ia4_page_contents__content,
.p-ia4_channel_region,
.p-ia4_channel_region__main,
.p-ia4_top_nav,
.p-ia4_sidebar,
.p-ia4_sidebar_header,
.p-ia4_sidebar__header,
.p-ia4_sidebar__body,
.p-ia4_sidebar__nav,
.p-ia4_nav,
.p-ia4_nav__container,
.p-ia4_nav__items,
.p-tab_rail,
.p-tab_rail__container,
.p-team_sidebar,
.p-team_sidebar__body,
.p-top_nav,
.p-channel_sidebar,
.p-channel_sidebar__static_list,
.p-channel_sidebar__navigation_bar,
.p-channel_sidebar__workspace_header,
.p-channel_sidebar__list,
.p-channel_sidebar__channel_section,
.p-channel_header,
.p-view_header,
.p-flexpane,
.p-flexpane_header,
.p-threads_view,
.p-threads_view__default_background,
.p-bookmarks_bar,
.p-workspace_banner,
.p-workspace__input,
.c-tabs,
.p-view_header__tabs {
  background: var(--omarchy-bg) !important;
  background-color: var(--omarchy-bg) !important;
  color: var(--omarchy-text) !important;
  border-color: var(--omarchy-border) !important;
}

/* Raised: composer, search, cards, menus, popovers */
.p-message_input,
.p-message_input_field,
.c-texty_input,
.c-texty_input__container,
.ql-container,
.p-composer_page__input,
.p-rich_text_input,
.p-top_nav__search,
.p-top_nav__search__container,
.c-search_autocomplete,
.p-search_filter,
.p-search_autocomplete,
.c-message_attachment,
.c-message_kit__file,
.c-file,
.c-basic_container,
.c-card,
.c-sk-modal,
.c-menu,
.c-popover,
.c-tooltip,
.p-channel_details_section,
.p-shortcuts_menu,
.p-emoji_picker,
.p-channel_search,
.p-browse_page,
.p-dm_browser,
.p-file_list,
.p-activity_page {
  background: var(--omarchy-raised) !important;
  background-color: var(--omarchy-raised) !important;
  color: var(--omarchy-text) !important;
  border-color: var(--omarchy-border) !important;
}

.p-message_input_field.focus,
.p-message_input_field:focus-within,
.p-top_nav__search:focus-within {
  border-color: var(--omarchy-accent) !important;
  box-shadow: 0 0 0 1px var(--omarchy-accent) !important;
}

/* ---------- Messages ---------- */

.c-message_kit__background,
.c-message_kit__gutter,
.c-message_kit__message,
.c-message_kit__thread_message,
.c-message,
.c-message__body,
.c-message_list__day_divider,
.c-message_list__day_divider__label {
  background: transparent !important;
}

.c-message_kit__message:hover,
.c-message_kit__background:hover,
.c-virtual_list__item:hover,
.p-channel_sidebar__channel:hover,
.p-channel_sidebar__link:hover,
.p-ia4_nav__item:hover,
.p-ia4_nav__button:hover,
.p-tab_rail__item:hover,
.p-tab_rail__button:hover {
  background: var(--omarchy-hover) !important;
}

/* ---------- Selection and navigation ---------- */

.p-channel_sidebar__channel--selected,
.p-channel_sidebar__link--selected,
.p-ia4_sidebar__item--selected,
.p-ia4_nav__item--selected,
.p-tab_rail__item--selected {
  background: var(--omarchy-accent-soft) !important;
  color: var(--omarchy-text) !important;
  box-shadow: inset 3px 0 0 var(--omarchy-accent) !important;
}

.c-tabs__tab--active,
.c-tabs__tab[aria-selected="true"] {
  color: var(--omarchy-text) !important;
  box-shadow: inset 0 -2px 0 var(--omarchy-accent) !important;
}

::selection {
  background: var(--omarchy-ember) !important;
  color: #ffffff !important;
}

/* ---------- Text ---------- */

.c-message_kit__text,
.c-message__body,
.c-message_kit__sender,
.c-message_kit__username,
.p-channel_header__channel_title,
.p-view_header__title,
.p-ia4_sidebar__item,
.p-ia4_nav__item,
.p-ia4_nav__button,
.p-tab_rail__item,
.p-tab_rail__button,
.p-channel_sidebar__channel,
.p-channel_sidebar__link {
  color: var(--omarchy-text) !important;
}

.c-message_kit__timestamp,
.c-timestamp,
.c-message_kit__metadata,
.p-channel_sidebar__channel_suffix,
.p-ia4_sidebar__item_subtitle,
.p-channel_sidebar__section_heading,
.p-channel_sidebar__section_heading_label {
  color: var(--omarchy-muted) !important;
}

.c-link,
a,
.c-mrkdwn__link,
.p-rich_text_section a,
.p-channel_sidebar__section_heading_plus {
  color: var(--omarchy-accent) !important;
}

.c-link:hover,
a:hover,
.c-mrkdwn__link:hover {
  text-decoration: underline !important;
}

/* ---------- Badges and reactions ---------- */

/* Dark text on accent fills: light text on crimson is only ~3.5:1 */
.p-channel_sidebar__badge,
.p-channel_sidebar__badge--unread,
.p-channel_sidebar__mention_badge,
.p-ia4_nav__badge,
.p-tab_rail__badge,
.c-mention_badge,
.c-unread_badge,
.p-channel_sidebar__unread_dot {
  background: var(--omarchy-accent) !important;
  color: var(--omarchy-bg) !important;
  box-shadow: none !important;
}

.c-reaction,
.c-reaction_add {
  background: var(--omarchy-raised) !important;
  border-color: var(--omarchy-border) !important;
  color: var(--omarchy-text) !important;
}

.c-reaction--reacted,
.c-reaction--reacted:hover {
  background: var(--omarchy-accent-soft) !important;
  border-color: var(--omarchy-accent) !important;
}

.c-reaction__count,
.c-reaction--reacted .c-reaction__count {
  color: var(--omarchy-text) !important;
}

/* ---------- Borders, code, scrollbars ---------- */

hr,
.c-divider,
.p-message_pane__unread_banner,
.c-message_list__day_divider__line {
  border-color: var(--omarchy-border) !important;
}

pre,
code,
.c-mrkdwn__pre,
.c-mrkdwn__code {
  background: var(--omarchy-raised) !important;
  color: var(--omarchy-text) !important;
  border-color: var(--omarchy-border) !important;
}

::-webkit-scrollbar {
  width: 10px !important;
  height: 10px !important;
}

::-webkit-scrollbar-track {
  background: var(--omarchy-bg) !important;
}

::-webkit-scrollbar-thumb {
  background: var(--omarchy-raised) !important;
  border: 2px solid var(--omarchy-bg) !important;
  border-radius: 999px !important;
}

::-webkit-scrollbar-thumb:hover {
  background: var(--omarchy-accent) !important;
}
