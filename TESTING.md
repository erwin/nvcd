# Testing

I'm a huge fan of automated testing.
Unfortunately for this kind of integration, I don't have a very good
idea off the top of my head for how to test things automatically.

In the mean time, I've made a list of tests to do manually that should
work, and help makesure that things don't degrade.

#### neovim health check
nvcd -c checkhealth

#### run some commands in neovim
nvcd --clean -c "echo('hi')"
nvcd --clean --cmd "echo('hi')"

nvcd --version

#### edit a file named "--clean"
nvcd --clean -- --clean

#### should be able to to open
sudo nvcd /etc/shadow

#### chinese file names should work fine
nvcd "当然汉语也行.md"

#### the tilde should be auto-expanded by nvcd
nvcd ~/.config/kitty/kitty.conf

#### Multiple files at the same time should be fine
cd /tmp
echo "foo,bar,baz" >> export.csv
echo "crazy file contents" >> "crazy file name.txt"
echo "other crazy one.txt" >> "other crazy one.txt"
nvcd export.csv crazy\ file\ name.txt other\ crazy\ one.txt

#### Versions of many files at once
mkdir -p "/tmp/nvcd-test"/{"nv s",nvcd,"sp ace","a b"}/{foo,bar,baz}
cd /tmp/nvcd-test
echo "1. FOO crazy config foo"       > "nv s/foo/config"
echo "2. BAR crazy config bar"       > "nv s/bar/config"
echo "3. BAZ crazy config baz"       > "nv s/baz/config"
echo "4. FOO max crazy config space" > "sp ace/foo/config"
echo "5. FOO almost empty file"      > "sp ace/foo/foo"
echo "6. BAR so many files"          > "a b/bar/test"
cd /tmp/nvcd-test/"sp ace"/foo
nvcd foo config ../../nv\ s/foo/config
nvcd foo config ../../nv\ s/foo/config ../../a\ b/bar/test
nvcd foo config ../../nv\ s/foo/config ../../a\ b/bar/test ~/.zshrc
nvcd -o foo config ../../nv\ s/foo/config ../../a\ b/bar/test ~/.zshrc
nvcd -O foo config ../../nv\ s/foo/config ../../a\ b/bar/test ~/.zshrc

