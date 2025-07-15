# kitty-swayssionizer

Inspired by
[tmux-sessionizer](https://github.com/ThePrimeagen/tmux-sessionizer), this
script launches a terminal "session" or switches focus to the session if it is
already running.

The script assumes you're using [sway](https://swaywm.org/), 
[kitty](https://sw.kovidgoyal.net/kitty/), and
[tofi](https://github.com/philj56/tofi), though switching it from kitty or tofi
to other terminal/menu programs isn't difficult.

## Usage

```sh
kitty-swayssionizer [session index] # The index being 0-3.
```

Ideally you probably want to bind the command to some shortcut, e.g.
`bindsym Mod4+Control+j = exec kitty-swayssionizer 0`.
