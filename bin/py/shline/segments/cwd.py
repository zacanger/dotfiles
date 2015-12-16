
def add_cwd_segment():
    import os

    def get_short_path(cwd):
        home = os.path.expanduser('~')
        if cwd.startswith(home):
            cwd = '~' + cwd[len(home):]
        names = cwd.split(os.sep)
        if not names[0]:
            names[0] = '/'
        return names

    cwd = shline.cwd or os.getenv('PWD')
    names = get_short_path(cwd.decode('utf-8'))

    max_depth = shline.args.cwd_max_depth
    if len(names) > max_depth:
        names = names[:2] + [u'\u2026'] + names[2 - max_depth:]

    shline.append(' %s ' % os.path.join(*names), Color.CWD_FG, Color.CWD_BG)

add_cwd_segment()
