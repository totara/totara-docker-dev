#!/usr/bin/env python3
"""Runs a command in a pseudo-terminal and answers the first [Y/n] or [y/N] prompt it shows.

Usage: run_in_terminal.py <answer> <command> [args...]

The answer is only typed once the prompt is showing. Input typed into a macOS terminal before the prompt can be lost,
which is what happened when the tests piped the answer into script(1).
"""

import os
import pty
import re
import select
import signal
import sys
import time

PROMPT = re.compile(rb"\[(Y/n|y/N)\] $")
TIMEOUT_SECONDS = 60


def main():
    answer = sys.argv[1].encode() + b"\n"
    command = sys.argv[2:]

    pid, fd = pty.fork()
    if pid == 0:
        os.execvp(command[0], command)

    output = b""
    answered = False
    deadline = time.monotonic() + TIMEOUT_SECONDS
    while True:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            os.kill(pid, signal.SIGKILL)
            os.waitpid(pid, 0)
            sys.stdout.write(output.decode(errors="replace"))
            sys.stdout.write("\nTimed out waiting for the command to finish\n")
            return 1

        ready, _, _ = select.select([fd], [], [], remaining)
        if not ready:
            continue
        try:
            chunk = os.read(fd, 4096)
        except OSError:
            # Linux raises EIO once the command has exited, macOS returns an empty read
            chunk = b""
        if not chunk:
            break

        output += chunk
        if not answered and PROMPT.search(output):
            os.write(fd, answer)
            answered = True

    _, status = os.waitpid(pid, 0)
    sys.stdout.write(output.decode(errors="replace"))
    return os.waitstatus_to_exitcode(status)


if __name__ == "__main__":
    sys.exit(main())
