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

### Testing On An Emulator

Many programs will work fine in the Nuance emulator, available here:

https://github.com/andkrau/NuanceResurrection

Just load the .cof file produced from the build in Nuance's file selection
dialog.

### Testing On NUON Hardware

To test on real Nuon hardware, you'll either need to burn a CD-R or CD-RW with
a NUON.CD file on it (Use track-at-once mode!) and put it in a Samsung N501,
N504, or N505 model Nuon player, or sign the .cof file and put it on a DVD in
the nuon directory. For best compatibility (I.e., to create a disc that will
work on the Toshiba SD2300 players), create the disc image using the MacOS
built-in DVD burning tool. You don't actually have to burn it from MacOS, just
create the UDF/ISO image there. Other tools create images that work fine on all
other known Nuon units, but not the Toshiba ones.

#### Testing using a CD-R or CD-RW

To create a NUON.CD file, use CreateNuonCD. This is a Windows-only tool at the
moment, so you'll need to install WINE first to use it on Linux. The Linux SDK
includes a wrapper script that detects and uses WINE when present. To speed up
loading times and save space, since NUON.CD files must be 4.5MB or smaller, you
will likely want to strip off debug and other unnecessary information from your
file and compress it using coffpack. Some examples:

Windows:
```
c:\Users\me\nuon-sdk\vmlabs\Sample\Hello-World>vmstrip -F -o hello.stripped.cof hello.cof
c:\Users\me\nuon-sdk\vmlabs\Sample\Hello-World>coffpack -o hello.packed.cof hello.stripped.cof
c:\Users\me\nuon-sdk\vmlabs\Sample\Hello-World>CreateNuonCD hello.cof
```

Linux:
```sh
$ vmstrip -F -o hello.stripped.cof hello.cof
$ coffpack -o hello.packed.cof hello.stripped.cof
$ CreateNuonCD hello.cof
```

For the SDK examples, this has actually been incorporated into the Makefiles, so
the initial above example that just runs "gmake" will already have created the
NUON.CD file.

Now burn this to a high-quality CD-R or CD-RW using the ISO9660 filesystem, and
using Track-At-Once (TAO) mode (As opposed to RAW, Disc-At-Once/DAO, or
Session-At-Once/SAO) and place it in a Samsung n501, n504, or n505 or RCA
DRC300N or DRC480N player and turn it on.

Note this is the only way to run games/homebrew software on the RCA units, but
you'll be limited to the remote for controls since they have no joystick ports,
and currently there's no known way to get sound working in games/homebrew apps
on these systems.

#### Testing using a DVD-R

To load Nuon programs from DVD, you'll first need to sign them, and then rename
them to "nuon.run" and place them in the appropriate directory on a DVD. To
create a nuon.run file that you can burn to a DVD-R and play on any Nuon player
that runs retail Nuon games, follow the above directions to generate a packed
COFF file, and then use the "vmmakeapp" script to sign it:

Windows:
```
c:\Users\me\nuon-sdk\vmlabs\Sample\Hello-World>vmmakeapp hello.packed.cof 0
c:\Users\me\nuon-sdk\vmlabs\Sample\Hello-World>rename hello.packed.cof.app nuon.run
```

Linux:
```sh
$ vmmakeapp hello.packed.cof 0
$ mv hello.packed.cof.app nuon.run
```

Then, place this signed nuon.run file in the "NUON" directory of a DVD image
using a UDF or hybrid UDF/ISO filesystem. For most players, you can use any DVD
burning software to generate the image and burn it, but NOTE that the only known
way to generate images that work on Toshiba SD2300 systems is to create the
image using MacOS's Disk Utility or DVD/CD burning software. The key step is
creating the image, so it's OK if your Mac doesn't have a DVD burner connected.
Tell Disk Utility to generate a "Universal" format image from the directory
containing your NUON directory, use the included MacOS DVD/CD creation program
to burn the directory directly to DVD, or use the command line equivalent to
generate an appropriate image:

MacOS:
```sh
$ mkdir MyNuonDVD
$ mkdir MyNuonDVD/NUON
$ mv nuon.run MyNuonDVD/NUON
$ hdiutil create -srcfolder MyNuonDVD -format UNIV -nospotlight -noanyowners MyNuonDVD.dmg
$ mv -v MyNuonDVD.dmg MyNuonDVD.iso
```

And then burn MyNuonDVD.iso to a DVD-R using your favorite DVD burning software
on any machine/OS. Then put the resulting DVD in your Nuon DVD player and start
it up!

NOTE: do NOT use DVD-RW, DVD+R, DVD+RW, or DVD-RAM discs. Some have reportedly
had success with DVD+R (I never have), so you can attempt those if you wish, but
I've not yet heard of anyone successfully loading anything from a rewriteable
DVD on a Nuon DVD player.

For more information on the process of signing COFF files for use on DVDs, refer
to this Nuon Dome forum thread post:

https://www.thehelper.net/threads/nuon-authentication-tools-thread-emulating-older-outdated-versions-of-linux.167407/page-3#post-1395445

## Acknowledgements

Many thanks to the VM labs employees for developing the Nuon technology and
releasing a public/homebrew SDK for it.

Special thanks to EdgeConnector and mgarcia for coercing the Nuon authentication
tools and signing keys included in this version of the SDK into working again
and porting them to Windows.
