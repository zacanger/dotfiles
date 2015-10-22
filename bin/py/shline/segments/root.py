
def add_root_indicator_segment():
    bg = Color.CMD_PASSED_BG
    fg = Color.CMD_PASSED_FG
    if shline.args.prev_error != 0:
        fg = Color.CMD_FAILED_FG
        bg = Color.CMD_FAILED_BG
    shline.append(' \\$ ', fg, bg)

add_root_indicator_segment()
