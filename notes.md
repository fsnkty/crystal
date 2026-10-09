# hjem/nix-maid, $HOME management
with hjem removed, likely in favor of `nix-maid` it may actually just make more sense to
create my own module to use (https://codeberg.org/viperML/kconfig-declarative) directly.
https://codeberg.org/viperML/nix-maid/src/branch/master/src/maid/modules/kconfig.nix
^ the module is actually very simple.

a reasonable example of kconfig-declarative usage (https://codeberg.org/DAWO/DAWO-Core/src/branch/main/modules/maid/dawo-generic.nix)

It may be possible to use the config generator from plasma-manager to figure out how to define this, though will likely need "translation"

making home files is fairly simple at surface level, which is all I care about anyway, so the fancy handling from hjem or even the much less fancy handling from nix-maid are both pretty excessive, and more inputs are almost always worse for me.

I used to handle it with simply https://github.com/fsnkty/crystal/blob/archive/all-selfhost/libs/homeFiles.nix


# lanzaboote, secure boot management.
lanzaboote has had the most success for me so far, but realistically should 
be replaced by limine. I originally switched *back* to lanzaboote because of limines lack of "hold key for menu" ability, but that ability didnt even reliably function on sysdboot anyway,
and it requires baby sitting the computer while the bios finishes up, ( usually not an issue but
my mother board is rediculously stupid and takes around 15~ sec to do this. ) sounds trivial but was actually quite annoying, So i turned it off anyway lol.

