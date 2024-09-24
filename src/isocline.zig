//! Bindings for isocline
//! See https://github.com/daanx/isocline/blob/main/include/isocline.h

const std = @import("std");

/// Read input from the user using rich editing abilities.
/// @param prompt_text   The prompt text, can be null for the default ("").
///   The displayed prompt becomes `prompt_text` followed by the `prompt_marker` ("> ").
/// @returns the heap allocated input on succes, which should be `free`d by the caller.
///   Returns null on error, or if the user typed ctrl+d or ctrl+c.
///
/// If the standard input (`stdin`) has no editing capability
/// (like a dumb terminal (e.g. `TERM`=`dumb`), running in a debugger, a pipe or redirected file, etc.)
/// the input is read directly from the input stream up to the
/// next line without editing capability.
pub fn readline(prompt: ?[*:0]const u8) ?[*:0]const u8 {
    return ic_readline(prompt);
}

/// Free a pointer that was allocated by the `readline` function.
pub fn free(ptr: [*]const u8) void {
    ic_free(@ptrCast(@constCast(ptr)));
}

/// Print to the terminal while respection bbcode markup.
/// Any unclosed tags are closed automatically at the end of the print.
/// For example:
/// ```
/// print("[b]bold, [i]bold and italic[/i], [red]red and bold[/][/b] default.", .{});
/// print("[b]bold[/], [i b]bold and italic[/], [yellow on blue]yellow on blue background", .{});
/// style_add("em","i color=#888800", .{});
/// print("[em]emphasis", .{});
/// ```
/// Properties that can be assigned are:
/// * `color=` _clr_, `bgcolor=` _clr_: where _clr_ is either a hex value `#`RRGGBB or `#`RGB, a
///    standard HTML color name, or an ANSI palette name, like `ansi-maroon`, `ansi-default`, etc.
/// * `bold`,`italic`,`reverse`,`underline`: can be `on` or `off`.
/// * everything else is a style; all HTML and ANSI color names are also a style (so we can just use `red`
///   instead of `color=red`, or `on red` instead of `bgcolor=red`), and there are
///   the `b`, `i`, `u`, and `r` styles for bold, italic, underline, and reverse.
///
/// See [here](https://github.com/daanx/isocline#bbcode-format) for a description of the full bbcode format.
pub fn print(comptime format: []const u8, args: anytype) void {
    std.fmt.format(writer, format, args) catch unreachable;
}

/// A writer that prints to the terminal while respection bbcode markup.
pub const writer: std.io.AnyWriter = .{
    .context = undefined,
    .writeFn = write,
};

fn write(_: *const anyopaque, bytes: []const u8) anyerror!usize {
    _ = bytes;
    @compileError("TODO: bytes is not 0-terminated");
    // ic_print(bytes);
    // return bytes.len;
}

/// Define or redefine a style.
/// @param style_name The name of the style.
/// @param fmt        The `fmt` string is the content of a tag and can contain
///   other styles. This is very useful to theme the output of a program
///   by assigning standard styles like `em` or `warning` etc.
pub fn styleDef(style_name: [*:0]const u8, fmt: [*:0]const u8) void {
    ic_style_def(style_name, fmt);
}

/// Start a global style that is only reset when calling a matching styleClose().
pub fn styleOpen(fmt: [*:0]const u8) void {
    ic_style_open(fmt);
}

/// End a global style.
pub fn styleClose() void {
    ic_style_close();
}

/// Enable history.
/// Use a null filename to not persist the history.
/// Use -1 for max_entries to get the default (200).
/// The last returned input from ic_readline() is automatically added to the history.
pub fn setHistory(fname: [*:0]const u8, max_entries: c_long) void {
    ic_set_history(fname, max_entries);
}

/// Remove the last entry in the history.
pub fn historyRemoveLast() void {
    ic_history_remove_last();
}

/// Clear the history.
pub fn historyClear() void {
    ic_history_clear();
}

/// Set a prompt marker and a potential marker for extra lines with multiline input.
/// The default marker is `"> "`.
/// Pass null for continuation prompt marker to make it equal to the `prompt_marker`.
pub fn setPromptMarker(prompt_marker: [*:0]const u8, continuation_prompt_marker: ?[*:0]const u8) void {
    ic_set_prompt_marker(prompt_marker, continuation_prompt_marker);
}

/// Disable or enable multi-line input (enabled by default).
/// Returns the previous setting.
pub fn enableMultiline(enable: bool) bool {
    return ic_enable_multiline(enable);
}

/// Disable or enable sound (enabled by default).
/// A beep is used when tab cannot find any completion for example.
/// Returns the previous setting.
pub fn enableBeep(enable: bool) bool {
    return ic_enable_beep(enable);
}

/// Disable or enable color output (enabled by default).
/// Returns the previous setting.
pub fn enableColor(enable: bool) bool {
    return ic_enable_color(enable);
}

/// Disable or enable duplicate entries in the history (disabled by default).
/// Returns the previous setting.
pub fn enableHistoryDuplicates(enable: bool) bool {
    return ic_enable_history_duplicates(enable);
}

/// Disable or enable automatic tab completion after a completion
/// to expand as far as possible if the completions are unique. (disabled by default).
/// Returns the previous setting.
pub fn enableAutoTab(enable: bool) bool {
    return ic_enable_auto_tab(enable);
}

/// Disable or enable preview of a completion selection (enabled by default)
/// Returns the previous setting.
pub fn enableCompletionPreview(enable: bool) bool {
    return ic_enable_completion_preview(enable);
}

/// Disable or enable automatic identation of continuation lines in multiline
/// input so it aligns with the initial prompt.
/// Returns the previous setting.
pub fn enableMultilineIndent(enable: bool) bool {
    return ic_enable_multiline_indent(enable);
}

/// Disable or enable display of short help messages for history search etc.
/// (full help is always dispayed when pressing F1 regardless of this setting)
/// @returns the previous setting.
pub fn enableInlineHelp(enable: bool) bool {
    return ic_enable_inline_help(enable);
}

/// Disable or enable hinting (enabled by default)
/// Shows a hint inline when there is a single possible completion.
/// @returns the previous setting.
pub fn enableHint(enable: bool) bool {
    return ic_enable_hint(enable);
}

/// Set millisecond delay before a hint is displayed. Can be zero. (500ms by default).
pub fn setHintDelay(delay_ms: c_long) c_long {
    return ic_set_hint_delay(delay_ms);
}

/// Disable or enable syntax highlighting (enabled by default).
/// This applies regardless whether a syntax highlighter callback was set (`ic_set_highlighter`)
/// Returns the previous setting.
pub fn enableHighlight(enable: bool) bool {
    return ic_enable_highlight(enable);
}

/// Set millisecond delay for reading escape sequences in order to distinguish
/// a lone ESC from the start of a escape sequence. The defaults are 100ms and 10ms,
/// but it may be increased if working with very slow terminals.
pub fn setTtyEscDelay(initial_delay_ms: c_long, followup_delay_ms: c_long) void {
    return ic_set_tty_esc_delay(initial_delay_ms, followup_delay_ms);
}

/// Enable highlighting of matching braces (and error highlight unmatched braces).`
pub fn enableBraceMatching(enable: bool) bool {
    return ic_enable_brace_matching(enable);
}

/// Set matching brace pairs.
/// Pass null for the default `"()[]{}"`.
pub fn setMatchingBraces(brace_pairs: ?[*:0]const u8) void {
    return ic_set_matching_braces(brace_pairs);
}

/// Enable automatic brace insertion (enabled by default).
pub fn enableBraceInsertion(enable: bool) bool {
    return ic_enable_brace_insertion(enable);
}

/// Set matching brace pairs for automatic insertion.
/// Pass null for the default `()[]{}\"\"''`
pub fn setInsertionBraces(brace_pairs: ?[*:0]const u8) void {
    return ic_set_insertion_braces(brace_pairs);
}

extern fn ic_readline(prompt_text: [*c]const u8) [*c]u8;
extern fn ic_free(p: ?*anyopaque) void;
extern fn ic_print(s: [*c]const u8) void;
extern fn ic_style_def(style_name: [*c]const u8, fmt: [*c]const u8) void;
extern fn ic_style_open(fmt: [*c]const u8) void;
extern fn ic_style_close() void;
extern fn ic_set_history(fname: [*c]const u8, max_entries: c_long) void;
extern fn ic_history_remove_last() void;
extern fn ic_history_clear() void;
extern fn ic_history_add(entry: [*c]const u8) void;
extern fn ic_set_prompt_marker(prompt_marker: [*c]const u8, continuation_prompt_marker: [*c]const u8) void;
extern fn ic_enable_multiline(enable: bool) bool;
extern fn ic_enable_beep(enable: bool) bool;
extern fn ic_enable_color(enable: bool) bool;
extern fn ic_enable_history_duplicates(enable: bool) bool;
extern fn ic_enable_auto_tab(enable: bool) bool;
extern fn ic_enable_completion_preview(enable: bool) bool;
extern fn ic_enable_multiline_indent(enable: bool) bool;
extern fn ic_enable_inline_help(enable: bool) bool;
extern fn ic_enable_hint(enable: bool) bool;
extern fn ic_set_hint_delay(delay_ms: c_long) c_long;
extern fn ic_enable_highlight(enable: bool) bool;
extern fn ic_set_tty_esc_delay(initial_delay_ms: c_long, followup_delay_ms: c_long) void;
extern fn ic_enable_brace_matching(enable: bool) bool;
extern fn ic_set_matching_braces(brace_pairs: [*c]const u8) void;
extern fn ic_enable_brace_insertion(enable: bool) bool;
extern fn ic_set_insertion_braces(brace_pairs: [*c]const u8) void;

// TODO: completion
// see https://github.com/daanx/isocline/blob/main/test/example.c
const struct_ic_completion_env_s = opaque {};
const ic_completion_env_t = struct_ic_completion_env_s;
const ic_completer_fun_t = fn (?*ic_completion_env_t, [*c]const u8) callconv(.C) void;
pub extern fn ic_set_default_completer(completer: ?*const ic_completer_fun_t, arg: ?*anyopaque) void;
extern fn ic_add_completion(cenv: ?*ic_completion_env_t, completion: [*c]const u8) bool;
extern fn ic_add_completion_ex(cenv: ?*ic_completion_env_t, completion: [*c]const u8, display: [*c]const u8, help: [*c]const u8) bool;
extern fn ic_add_completions(cenv: ?*ic_completion_env_t, prefix: [*c]const u8, completions: [*c][*c]const u8) bool;
extern fn ic_complete_filename(cenv: ?*ic_completion_env_t, prefix: [*c]const u8, dir_separator: u8, roots: [*c]const u8, extensions: [*c]const u8) void;
const ic_is_char_class_fun_t = fn ([*c]const u8, c_long) callconv(.C) bool;
extern fn ic_complete_word(cenv: ?*ic_completion_env_t, prefix: [*c]const u8, fun: ?*const ic_completer_fun_t, is_word_char: ?*const ic_is_char_class_fun_t) void;
extern fn ic_complete_qword(cenv: ?*ic_completion_env_t, prefix: [*c]const u8, fun: ?*const ic_completer_fun_t, is_word_char: ?*const ic_is_char_class_fun_t) void;
extern fn ic_complete_qword_ex(cenv: ?*ic_completion_env_t, prefix: [*c]const u8, fun: ?*const ic_completer_fun_t, is_word_char: ?*const ic_is_char_class_fun_t, escape_char: u8, quote_chars: [*c]const u8) void;
extern fn ic_completion_input(cenv: ?*ic_completion_env_t, cursor: [*c]c_long) [*c]const u8;
extern fn ic_completion_arg(cenv: ?*const ic_completion_env_t) ?*anyopaque;
extern fn ic_has_completions(cenv: ?*const ic_completion_env_t) bool;
extern fn ic_stop_completing(cenv: ?*const ic_completion_env_t) bool;
extern fn ic_add_completion_prim(cenv: ?*ic_completion_env_t, completion: [*c]const u8, display: [*c]const u8, help: [*c]const u8, delete_before: c_long, delete_after: c_long) bool;

// TODO: highlight
// see https://github.com/daanx/isocline/blob/main/test/example.c
const struct_ic_highlight_env_s = opaque {};
const ic_highlight_env_t = struct_ic_highlight_env_s;
const ic_highlight_fun_t = fn (?*ic_highlight_env_t, [*c]const u8, ?*anyopaque) callconv(.C) void;
extern fn ic_set_default_highlighter(highlighter: ?*const ic_highlight_fun_t, arg: ?*anyopaque) void;
extern fn ic_highlight(henv: ?*ic_highlight_env_t, pos: c_long, count: c_long, style: [*c]const u8) void;
const ic_highlight_format_fun_t = fn ([*c]const u8, ?*anyopaque) callconv(.C) [*c]u8;
extern fn ic_highlight_formatted(henv: ?*ic_highlight_env_t, input: [*c]const u8, formatted: [*c]const u8) void;

extern fn ic_readline_ex(prompt_text: [*c]const u8, completer: ?*const ic_completer_fun_t, completer_arg: ?*anyopaque, highlighter: ?*const ic_highlight_fun_t, highlighter_arg: ?*anyopaque) [*c]u8;

// TODO: helper
extern fn ic_prev_char(s: [*c]const u8, pos: c_long) c_long;
extern fn ic_next_char(s: [*c]const u8, pos: c_long) c_long;
extern fn ic_starts_with(s: [*c]const u8, prefix: [*c]const u8) bool;
extern fn ic_istarts_with(s: [*c]const u8, prefix: [*c]const u8) bool;
extern fn ic_char_is_white(s: [*c]const u8, len: c_long) bool;
extern fn ic_char_is_nonwhite(s: [*c]const u8, len: c_long) bool;
extern fn ic_char_is_separator(s: [*c]const u8, len: c_long) bool;
extern fn ic_char_is_nonseparator(s: [*c]const u8, len: c_long) bool;
extern fn ic_char_is_letter(s: [*c]const u8, len: c_long) bool;
extern fn ic_char_is_digit(s: [*c]const u8, len: c_long) bool;
extern fn ic_char_is_hexdigit(s: [*c]const u8, len: c_long) bool;
extern fn ic_char_is_idletter(s: [*c]const u8, len: c_long) bool;
extern fn ic_char_is_filename_letter(s: [*c]const u8, len: c_long) bool;
extern fn ic_is_token(s: [*c]const u8, pos: c_long, is_token_char: ?*const ic_is_char_class_fun_t) c_long;
extern fn ic_match_token(s: [*c]const u8, pos: c_long, is_token_char: ?*const ic_is_char_class_fun_t, token: [*c]const u8) c_long;
extern fn ic_match_any_token(s: [*c]const u8, pos: c_long, is_token_char: ?*const ic_is_char_class_fun_t, tokens: [*c][*c]const u8) c_long;

// TODO: term
extern fn ic_term_init() void;
extern fn ic_term_done() void;
extern fn ic_term_flush() void;
extern fn ic_term_write(s: [*c]const u8) void;
extern fn ic_term_writeln(s: [*c]const u8) void;
extern fn ic_term_writef(fmt: [*c]const u8, ...) void;
extern fn ic_term_style(style: [*c]const u8) void;
extern fn ic_term_bold(enable: bool) void;
extern fn ic_term_underline(enable: bool) void;
extern fn ic_term_italic(enable: bool) void;
extern fn ic_term_reverse(enable: bool) void;
extern fn ic_term_color_ansi(foreground: bool, color: c_int) void;
extern fn ic_term_color_rgb(foreground: bool, color: u32) void;
extern fn ic_term_reset() void;
extern fn ic_term_get_color_bits() c_int;

// TODO: custom alloc
const ic_malloc_fun_t = fn (usize) callconv(.C) ?*anyopaque;
const ic_realloc_fun_t = fn (?*anyopaque, usize) callconv(.C) ?*anyopaque;
const ic_free_fun_t = fn (?*anyopaque) callconv(.C) void;
extern fn ic_init_custom_alloc(_malloc: ?*const ic_malloc_fun_t, _realloc: ?*const ic_realloc_fun_t, _free: ?*const ic_free_fun_t) void;
