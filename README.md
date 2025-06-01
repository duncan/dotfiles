# Duncan’s Dotfiles

Dotfiles are how you personalize a system. These are mine. They’ve changed a lot
over the years. They’ll probably keep changing. That's the way of it all, innit?

One of the biggest changes recently is the move from Homebrew to
[Flox](https://flox.dev). This is thanks to my time at Shopify where [Tobi
Lütke](https://github.com/tobi) and Burke Libbey turned me onto Nix and it’s
ability to maintain different tooling configs on a per-project basis.

# Install

I clone my dotfiles repo into `~/src` because it’s under source code management
like everything else. Others clone their dotfiles into `~/.dotfiles`. Whatever
floats your boat.

The “safe” way to do this is:

```
mkdir -p ~/src
git clone https://github.com/duncan/dotfiles ~/src/dotfiles
cd ~/src/dotfiles
./install.sh
```

Or, you can go full out and do that thing that we really don’t suggest folks do
and pipe the setup script right off of GitHub and into your shell:

```
curl https://raw.githubusercontent.com/duncan/dotfiles/main/install.sh | bash
```
