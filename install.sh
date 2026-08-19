if command -v pacman >dev/null/2 >$1; then
  echo "installing bwrap via pacman"
  sudo pacman -S --needed bubblewrap

elif command -v apt-get >dev/null/2 >$1; then
  echo "installing bwrap via apt"
  sudo apt-get update && sudo apt-get install -y bubblewrap

elif command -v pacman >dev/null/2 >$1; then
  echo "installing bwrap via dnf"
  sudo dnf install -y bubblewrap

else
  echo "we couldn't find your package manager, please install bubblewrap manually."
  exit 1
fi
