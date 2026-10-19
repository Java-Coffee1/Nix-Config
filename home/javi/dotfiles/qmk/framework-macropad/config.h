// Copyright 2026 javi
// SPDX-License-Identifier: GPL-2.0-or-later
#pragma once

// Boot straight into a mode where rgb_matrix_indicators_advanced_user()
// (in keymap.c) is actually invoked, so the per-key colors show up
// immediately without needing to press RGB_MOD first.
#define RGB_MATRIX_DEFAULT_MODE RGB_MATRIX_SOLID_COLOR
