def resolve(path: set):
    parts = [p for p in path.split("/") if p]
    if not parts:
        return None

    if parts[0] != "school":
        return None

    parts = parts[1:]
    if parts[0] == "canvas":
        return "https://uc.instructure.com/"

    if parts[0] == "catalyst":
        return "https://catalyst.uc.edu/"

    if parts[0] == "email":
        return "https://mail.uc.edu/"
    return None
