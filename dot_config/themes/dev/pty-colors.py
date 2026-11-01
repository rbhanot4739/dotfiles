#!/usr/bin/env python3
"""Dev-only helper: run a full-screen program in a pseudo terminal and print the 24-bit
colours it draws (as #rrggbb), so a theme switch can be checked without eyes.

usage: pty-colors.py [--secs N] [--send TEXT] -- cmd [args...]
  --secs  how long to let the program draw before quitting it (default 2)
  --send  keys to send afterwards (default: Esc, then q) ; python escapes like \\x1b work
"""
import fcntl, os, pty, re, select, struct, sys, termios, time

args = sys.argv[1:]
secs, send = 2.0, "\x1bq"
while args and args[0] != "--":
    if args[0] == "--secs": secs = float(args[1]); args = args[2:]
    elif args[0] == "--send": send = args[1].encode().decode("unicode_escape"); args = args[2:]
    else: sys.exit(__doc__)
cmd = args[1:]
if not cmd: sys.exit(__doc__)

env = dict(os.environ, TERM="xterm-256color", COLORTERM="truecolor")
pid, fd = pty.fork()
if pid == 0:
    os.execvpe(cmd[0], cmd, env)
fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", 40, 120, 0, 0))

buf = b""
def drain(limit):
    global buf
    end = time.time() + limit
    while time.time() < end:
        r, _, _ = select.select([fd], [], [], 0.1)
        if r:
            try: chunk = os.read(fd, 65536)
            except OSError: return
            if not chunk: return
            buf += chunk
            # a real terminal answers these queries; fzf --height waits for the cursor position
            try:
                if b"\x1b[6n" in chunk: os.write(fd, b"\x1b[1;1R")
                if b"\x1b[c" in chunk: os.write(fd, b"\x1b[?1;2c")
            except OSError: return

drain(secs)
try: os.write(fd, send.encode())
except OSError: pass
drain(0.5)
try: os.kill(pid, 9)
except OSError: pass

txt = buf.decode(errors="replace")
found = {"#%02x%02x%02x" % tuple(map(int, c.split(";"))) for c in re.findall(r"[34]8;2;(\d+;\d+;\d+)", txt)}
print(" ".join(sorted(found)))
