
def add_username_segment():
    import os

    if os.getenv('USER') == 'root':
        bgcolor = Color.USERNAME_ROOT_BG
    else:
        bgcolor = Color.USERNAME_BG

    shline.append(' \\u ', Color.USERNAME_FG, bgcolor)

add_username_segment()
