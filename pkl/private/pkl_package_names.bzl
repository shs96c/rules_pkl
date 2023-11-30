_TRANSFORM_TO_UNDERSCORE = ["/", "@", ".", "-"]

def transform_package_url_to_workspace_name(name):
    if "://" not in name:
        fail("Name does not look like it's a URL. ", name)

    to_return = name.partition("://")[2]

    for symbol in _TRANSFORM_TO_UNDERSCORE:
        to_return = to_return.replace(symbol, "_")

    return to_return

def get_terminal_package_name(url):
    return url.rpartition("/")[2]
