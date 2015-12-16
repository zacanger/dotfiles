
def add_read_only_segment():
    import os

    cwd = shline.cwd or os.getenv('PWD')
    if not os.access(cwd, os.W_OK):
        shline.append(' %s ' % shline.lock, Color.READONLY_FG, Color.READONLY_BG)

add_read_only_segment()
