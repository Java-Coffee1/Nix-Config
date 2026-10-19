// Copyright 2026 javi
// SPDX-License-Identifier: GPL-2.0-or-later
//
// Custom keymap for the Framework Laptop 16 RGB Macropad
// (keyboard: framework/macropad, keymap: javi).
//
// Build:  qmk compile -kb framework/macropad -km javi
// Flash:  qmk flash   -kb framework/macropad -km javi
// Bootloader access: no in-keymap combo for this anymore — use whatever
// other method you have (e.g. a physical BOOTSEL point) to get into
// QK_BOOT.
//
// Pos 1-4 (the top row of small keys) are an A/B/C/D config switcher:
// each one jumps to a real QMK layer (_LAYER_A.._LAYER_D below), so
// tapping one changes what every other key on the pad does, not just an
// indicator. To customize a config, edit two things, both indexed the
// same way (pos 1..24, matching the LAYOUT() argument order):
//   - that config's block in keymaps[] below, for what each key DOES
//   - that config's row in config_colors[] below, for what each key
//     LOOKS like while that config is active
// Pos 8/12 are brightness down/up (RGB_VAD/RGB_VAI) on Sets A/B/C — the
// brightness level itself is shared across every set, so these just give
// you a way to reach it from wherever you are. Set D is a standard numpad
// (see its block in keymaps[]/config_colors[] below) with no brightness
// keys of its own. Sets A/B/C's remaining keys still just type
// "1"/"2"/"3" as a placeholder.
//
// Physical layout (6 rows x 4 cols, 24 keys), position numbers used
// throughout this file match this grid and the LAYOUT() argument order
// below:
//
//   ┌────┬────┬────┬────┐
//   │  1 │  2 │  3 │  4 │
//   ├────┼────┼────┼────┤
//   │  5 │  6 │  7 │  8 │
//   ├────┼────┼────┼────┤
//   │  9 │ 10 │ 11 │ 12 │
//   ├────┼────┼────┼────┤
//   │ 13 │ 14 │ 15 │ 16 │
//   ├────┼────┼────┼────┤
//   │ 17 │ 18 │ 19 │ 20 │
//   ├────┼────┼────┼────┤
//   │ 21 │ 22 │ 23 │ 24 │
//   └────┴────┴────┴────┘

#include QMK_KEYBOARD_H

// VIA_ENABLE means this board keeps a *separate* copy of the keymap in
// EEPROM (the "dynamic keymap"), copied from whatever was compiled in
// the very first time EEPROM's VIA magic byte was valid — every flash
// since then has had zero runtime effect, because via_init() only
// re-copies from the compiled keymaps[] below when that magic is
// invalid. keyboard_pre_init_user() runs during keyboard_setup(), which
// is before keyboard_init() calls via_init() — invalidating it here
// forces a fresh copy from keymaps[] on every single boot, so this file
// is actually always what's running (no editing via VIA's own GUI
// either, at that point — this keymap is the only source of truth).
void keyboard_pre_init_user(void) {
    via_eeprom_set_valid(false);
}

// Named _LAYER_* (not _BASE/_FN) because macropad.h already declares its
// own `enum _layers { _NUMLOCK, _FN, _FACTORY };` at the keyboard level,
// and _FN would collide with that.
enum layers {
    _LAYER_A,
    _LAYER_B,
    _LAYER_C,
    _LAYER_D,
};

// Pos 1-4 on every config layer: tap any of these from any config to
// jump straight to another one. Custom keycodes (not TO()) so the LED
// below can be driven directly from the switch-case that handles the
// press, instead of reading layer_state back — one source of truth, so
// a wrong LED lighting up means pos_to_led/the physical key itself is
// mismatched, not a layer-state read bug.
enum custom_keycodes {
    CONFIG_A = SAFE_RANGE,
    CONFIG_B,
    CONFIG_C,
    CONFIG_D,
};

// MACRO(n) sends Ctrl+Shift+Alt+Fn as a single keypress — a 3-modifier
// chord nothing else uses, bound on the host (keybindings.lua) to run a
// script. MACRO(1) is Ctrl+Shift+Alt+F1, MACRO(2) is F2, etc, up through
// MACRO(24); n is pasted directly onto KC_F so it must match an existing
// KC_F<n> keycode.
#define MACRO(n) LCTL(LSFT(LALT(KC_F##n)))

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_LAYER_A] = LAYOUT(
        CONFIG_A, CONFIG_B, CONFIG_C, CONFIG_D,
        KC_NO, KC_NO,    KC_NO, RGB_VAD,
        MACRO(9),    KC_NO,    MACRO(10),    RGB_VAI,
        KC_NO,    KC_NO,    KC_NO,    KC_NO,
        MACRO(5),    MACRO(6),    MACRO(7),    MACRO(8),
        MACRO(1), MACRO(2), MACRO(3), MACRO(4)
    ),
    [_LAYER_B] = LAYOUT(
        CONFIG_A, CONFIG_B, CONFIG_C, CONFIG_D,
        KC_NO,    KC_NO,    KC_NO, RGB_VAD,
        KC_NO,    KC_NO,    KC_NO,    RGB_VAI,
        KC_NO,    KC_NO,    KC_NO,    KC_NO,
        KC_NO,    KC_NO,    KC_NO,    KC_NO,
        KC_NO, KC_NO, KC_NO, KC_NO
    ),
    [_LAYER_C] = LAYOUT(
        CONFIG_A, CONFIG_B, CONFIG_C, CONFIG_D,
        KC_NO,    KC_NO,    KC_NO, RGB_VAD,
        KC_NO,    KC_NO,    KC_NO,    RGB_VAI,
        KC_NO,    KC_NO,    KC_NO,    KC_NO,
        KC_NO,    KC_NO,    KC_NO,    KC_NO,
        KC_NO, KC_NO, KC_NO, KC_NO
    ),
    [_LAYER_D] = LAYOUT(
        CONFIG_A, CONFIG_B, CONFIG_C, CONFIG_D,
        KC_NO,   KC_NO,   KC_NO,   KC_NO,
        KC_P1,   KC_P2,   KC_P3,   KC_PAST,
        KC_P4,   KC_P5,   KC_P6,   KC_PPLS,
        KC_P7,   KC_P8,   KC_P9,   KC_PMNS,
        KC_PEQL, KC_P0, KC_PSLS, KC_PENT
    ),
};

// Which config (pos 1-4) is active — set directly by process_record_user
// below, read directly by the LED logic. No layer_state involved.
static uint8_t active_config = 0;

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (record->event.pressed) {
        switch (keycode) {
            case CONFIG_A:
                active_config = 0;
                layer_move(_LAYER_A);
                return false;
            case CONFIG_B:
                active_config = 1;
                layer_move(_LAYER_B);
                return false;
            case CONFIG_C:
                active_config = 2;
                layer_move(_LAYER_C);
                return false;
            case CONFIG_D:
                active_config = 3;
                layer_move(_LAYER_D);
                return false;
        }
    }
    return true;
}

// RGB Matrix LED index for each of the 24 physical positions above.
// This comes from this keyboard's own g_led_config (key matrix -> LED
// index) in keyboards/framework/macropad/macropad.c combined with the
// LAYOUT() argument order in macropad.h, both on the FrameworkComputer
// qmk_firmware fork, branch fl16-2026-f9 — it is NOT derivable from this
// file alone, so don't reorder this table without re-deriving it.
static const uint8_t pos_to_led[24] = {
     5,  2, 22, 17,
     4,  0, 20, 18,
     7,  1, 21, 16,
     6,  3, 23, 19,
     9, 11, 15, 13,
     8, 10, 14, 12,
};

// Per-config, per-button color: config_colors[set][pos] is the RGB for
// position pos (1..24, 0-indexed) while that config (Set A/B/C/D) is
// active. This covers the switcher row (pos 1-4) too — there's no "dim
// the inactive switcher keys" rule in code anymore, so if you want a
// switcher key lit in some config, put its color in that config's own
// row (see Set B/C's own index below); if you don't, leave it {0,0,0}
// like Set A does for its own index 0 and Set D does for everything.
static const uint8_t config_colors[4][24][3] = {
    // Set A: pos 1 (page-select indicator) red, pos 8 (RGB_VAD, brightness
    // down) dim yellow, pos 12 (RGB_VAI, brightness up) full yellow,
    // everything else a low dim white so brightness changes are visible
    // across the whole pad. Pos 13-20 are the MACRO(5-8)/MACRO(1-4) app
    // launchers, each colored to match its app: outline (teal), copyparty
    // (amber), onshape (sky blue), gmail (red), firefox (orange), discord
    // (blurple), vscode (blue), slack (aubergine).
    [_LAYER_A] = {
        { 255,   0,   0 }, {  0,  0,  0 }, {  0,  0,  0 }, {  0,  0, 0 },
        {  0,  0,  0 }, {  0,  0,  0 }, {  0,  0,  0 }, {  80,  80,   0 },
        {  0,  0,  0 }, {  0,  0,  0 }, {  0,  0,  0 }, { 250, 255,   0 },
        {  0,  0,  0 }, {  0,  0,  0 }, {  0,  0,  0 }, {  0,  0,  0 },
        {  0, 180, 150 }, { 230, 160,  20 }, {  30, 170, 230 }, { 234,  67,  53 },
        { 255,  90,   0 }, {  88, 101, 242 }, {   0, 122, 204 }, { 120,  40, 130 },
    },
    // Set B: its own switcher key (pos 2) red, rest of the switcher
    // row off, other 20 keys a rainbow (same one all configs used to
    // share, now just living here).
    [_LAYER_B] = {
        {   0,   0,   0 }, { 255, 0,   0 }, {   0,   0,   0 }, {   0,   0,   0 },
        { 255, 255,   0 }, { 191, 255,   0 }, { 128, 255,   0 }, {  64, 255,   0 },
        {   0, 255,   0 }, {   0, 255,  64 }, {   0, 255, 128 }, {   0, 255, 191 },
        {   0, 255, 255 }, {   0, 191, 255 }, {   0, 128, 255 }, {   0,  64, 255 },
        {   0,   0, 255 }, {  64,   0, 255 }, { 128,   0, 255 }, { 191,   0, 255 },
        { 255,   0, 255 }, { 255,   0, 191 }, { 255,   0, 128 }, { 255,   0,  64 },
    },
    // Set C: same idea, its own switcher key (pos 3) red.
    [_LAYER_C] = {
        {   0,   0,   0 }, {   0,   0,   0 }, { 255, 0,   0 }, {   0,   0,   0 },
        { 255, 255,   0 }, { 191, 255,   0 }, { 128, 255,   0 }, {  64, 255,   0 },
        {   0, 255,   0 }, {   0, 255,  64 }, {   0, 255, 128 }, {   0, 255, 191 },
        {   0, 255, 255 }, {   0, 191, 255 }, {   0, 128, 255 }, {   0,  64, 255 },
        {   0,   0, 255 }, {  64,   0, 255 }, { 128,   0, 255 }, { 191,   0, 255 },
        { 255,   0, 255 }, { 255,   0, 191 }, { 255,   0, 128 }, { 255,   0,  64 },
    },
    // Set D: a standard numpad, calculator-style (3 numbers + 1 operator
    // per row). Its own switcher key (pos 4) red like the others. Numbers
    // blue, each math function its own color (* purple, + green, -
    // orange, / cyan, = magenta), Enter white, unused keys off.
    [_LAYER_D] = {
        {   0,   0,   0 }, {   0,   0,   0 }, {   0,   0,   0 }, { 255,   0,   0 },
        {   0,   0,   0 }, {   0,   0,   0 }, {   0,   0,   0 }, {   0,   0,   0 },
        {   0,   0, 255 }, {   0,   0, 255 }, {   0,   0, 255 }, { 128,   0, 255 },
        {   0,   0, 255 }, {   0,   0, 255 }, {   0,   0, 255 }, {   0, 255,   0 },
        {   0,   0, 255 }, {   0,   0, 255 }, {   0,   0, 255 }, { 255, 128,   0 },
        { 255,   0, 255 }, {   0,   0, 255 }, {   0, 255, 255 }, { 255, 255, 255 },
    },
};

// Both keyboard_post_init_user() (keyboards/framework/macropad/macropad.c,
// for numlock sync) AND keyboard_post_init_kb() (keyboards/framework/
// framework.c, which calls the former) are already non-weakly defined by
// Framework's own firmware, so neither is available to override from a
// keymap without a link error. housekeeping_task_user() is unclaimed and
// runs every main loop iteration (well after all init, including
// rgb_matrix loading its EEPROM config) — using a one-shot latch here
// instead to force a known-good RGB state once at boot.
void housekeeping_task_user(void) {
    static bool rgb_forced = false;
    if (!rgb_forced) {
        rgb_forced = true;
        // RGB Matrix config (enable/mode/brightness) persists in EEPROM
        // across flashes, so a previous keymap leaving it off/dimmed/in a
        // different mode would otherwise make this keymap's colors not
        // show up at all. Force it without touching EEPROM.
        rgb_matrix_enable_noeeprom();
        rgb_matrix_mode_noeeprom(RGB_MATRIX_SOLID_COLOR);
        rgb_matrix_sethsv_noeeprom(0, 0, 255);
    }
}

bool rgb_matrix_indicators_advanced_user(uint8_t led_min, uint8_t led_max) {
    for (uint8_t pos = 0; pos < 24; pos++) {
        uint8_t led = pos_to_led[pos];
        if (led >= led_min && led < led_max) {
            const uint8_t *color = config_colors[active_config][pos];
            uint8_t r = color[0];
            uint8_t g = color[1];
            uint8_t b = color[2];

            // Scale by the current RGB_VAI/VAD brightness setting, since
            // rgb_matrix_set_color() writes raw values with no brightness
            // scaling applied on top.
            uint8_t v = rgb_matrix_config.hsv.v;
            rgb_matrix_set_color(
                led,
                (uint8_t)((uint16_t)r * v / 255),
                (uint8_t)((uint16_t)g * v / 255),
                (uint8_t)((uint16_t)b * v / 255)
            );
        }
    }
    return true;
}
