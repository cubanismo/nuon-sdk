# Nuon SDK/Development Tools

This is an amalgamation of the Nuon Linux and Windows SDK files into one
location, and configured to function correctly without any system-wide install
step. Just clone this repo, run env.bat from a command prompt on Windows:

```
C:\Users\me\nuon-sdk>env.bat
```

Or source env.sh on Linux:

```sh
$ . env.sh
```

Note env.sh currently only works in bash shells. Patches for other shells
welcome.

A few tools aren't yet available on Linux, so a few samples won't build there,
and you'll need to switch to Windows for now to create NUON.CD files, but
otherwise the environments should be equivalent.

## Usage/Examples/Getting started

Once you've cloned this repo and initialized your environment as described
above, you can build some of the included samples. Note you have to re-run the
env.bat or re-source the env.sh program each time you start a new command prompt
or terminal.

To get started, try building the included Hello-World example program:

Windows:
```
C:\Users\me\nuon-sdk>env.bat
C:\Users\me\nuon-sdk>cd vmlabs\Sample\Hello-World
C:\Users\me\nuon-sdk\vmlabs\Sample\Hello-World>gmake
```

Linux:
```sh
$ . env.sh
$ cd vmlabs/sample/Hello-World
$ gmake
```

This will produce a hello.cof file you can load in Nuance. Give it a try!

After that, try adapting one of the more complex sample programs to do what
you want it to. Good starting points are Game-Controllers/DeadZone and
Sprites/VMBalls4.

## Testing/Running programs

Many programs will work fine in the Nuance emulator, available here:

https://github.com/andkrau/NuanceResurrection

Just load the .cof file produced from the build in Nuance's file selection
dialog.

To test on real Nuon hardware, you'll either need to burn a CD-R or CD-RW with
the generated NUON.CD file on it (Use track-at-once mode!) and put it in a
Samsung N501, N504, or N505 model Nuon player, or sign the .cof file and put it
on a DVD in the nuon directory. For best compatibility (I.e., to create a disc
that will work on the Toshiba SD2300 players), create the disc image using the
MacOS built-in DVD burning tool. Other tools create images that work fine on all
other known Nuon units, but not the Toshiba ones.

For more information on how to signing COFF files for use on DVDs, refer to this
Nuon Dome forum thread post:

https://www.thehelper.net/threads/nuon-authentication-tools-thread-emulating-older-outdated-versions-of-linux.167407/page-3#post-1395445

I hope to integrate the signing process with this SDK in the future, but right
now it's a separate manual step. Note there are win32 versions of the signing
tools attached later in that thread if you're on Windows and don't want to set
up the whole virtual machine or aren't comfortable with Linux command line
tools.

## Acknowledgements

Many thanks to the VM labs employees for developing the Nuon technology and
releasing a public/homebrew SDK for it.

Special thanks to EdgeConnector and mgarcia for coercing the Nuon authentication
tools and signing keys included in this version of the SDK into working again
and porting them to Windows.
