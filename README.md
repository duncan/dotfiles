# Duncan’s dotfiles

You know, [dotfiles](https://dotfiles.github.io).

I have moved away from using helper tools like [yadm][y] and [chezmoi][c]. Those tools are really useful and I admire them a lot. However, I use these dotfiles in a lot of places, including ones where minimizing the number of software supply chain dependencies is important. As well, the remote compute environments I’m using more of (such as GitHub Codespces) are [adopting conventions for dotfile installation][d] that take on some of that job.

To use:

1. Clone this repository to `~/dotfiles`
2. Run `setup`
3. There is no step 3.

**Warning:** If you're not Duncan, you probably don't want to use this verbatim. 

[y]: https://yadm.io
[c]: https://www.chezmoi.io
[d]: https://docs.github.com/en/codespaces/setting-up-your-codespace/personalizing-codespaces-for-your-account