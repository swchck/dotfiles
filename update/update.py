import os

if __name__ == '__main__':
    os.chdir('~/dotfiles')
    os.system('git fetch && git pull')
    os.system('rcup')
