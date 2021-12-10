get_bin = lambda x, n: format(x, "b").zfill(n)
get_hex = lambda x, n: format(x, "x").zfill(n)


class AnsiColor:
    RESET_COLOR = "\033[0m"
    SIGN_COLOR = "\033[1;37;41m"
    REG_COLOR = "\033[1;30;43m"
    EXP_COLOR = "\033[1;37;44m"
    MANT_COLOR = "\033[1;37;40m"
    ANSI_COLOR_CYAN = "\x1b[36m"
    ANSI_COLOR_GREY = "\x1b[90m"


dbg_print = lambda s: print(f"{AnsiColor.ANSI_COLOR_GREY}{s}{AnsiColor.RESET_COLOR}")


def shl(bits, rhs, size):
    """shift left on `size` bits"""
    mask = (2 ** size) - 1
    # if rhs < 0:
    #     dbg_print("shl shifted by a neg number")
    return (bits << rhs) & mask if rhs > 0 else (bits >> -rhs)


def shr(bits, rhs, size):
    """shift right"""
    mask = (2 ** size) - 1
    # if rhs < 0:
    #     dbg_print("shr shifted by a neg number")
    return (bits >> rhs) if rhs > 0 else (bits << -rhs) & mask


def c2(bits, size):
    """two's complement on `size` bits"""
    mask = (2 ** size) - 1
    return (~bits & mask) + 1
