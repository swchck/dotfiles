import os
import platform

from configure import install
from questions import get_questions
from PyInquirer import prompt


def main():
    if platform.system() == 'Darwin':
        os.system('xcode-select --install')

    if os.system('which -s brew') != 0:
        os.system('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
    else:
        print("Brewery already installed, Skipping...")

    install(prompt(questions=get_questions))


if __name__ == '__main__':
    os.system('clear')
    main()
