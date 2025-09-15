+++
title = "My Setup"
date = "2024-12-21"

[taxonomies]
tags=["Setup"]
+++


## Nix (Just for common packages)

I don't really want to move to full-fledged nix setup because it's a lot of
effort. However, I do want to keep some of my common packages/tools in version
control, so that it's easy for me to set them up easily when (if) I move my
setup.

### nix-env

- Install nix
- Add the unstable channel so that I have mostly latest versions.
```sh
$ nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
```

- Update the channels
```sh
$ nix-channel --update
```

- Install my stuff 

```sh
$ nix-env -iA nixpkgs.myPackages
```

- My config is stored in my [dotfiles repo](https://github.com/dipeshkaphle/dotfiles/tree/master/nixpkgs)


## Emacs (Primary Editor)

- Doom emacs with my configs piling up over the time. [Link](https://github.com/dipeshkaphle/dotfiles/tree/master/.doom.d), [tips and tricks for myself](https://dipeshkaphle.github.io/posts/helpful-emacs-shortcuts/)

