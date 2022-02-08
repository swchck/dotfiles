import os
import questions
import subprocess

from PyInquirer import prompt


def configure_bash():
    os.system('chsh -s $(which bash)')


def configure_zsh():
    if os.system('which -s zsh') == '':
        os.system('brew install zsh')
        os.system('sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"')
    os.system('chsh -s $(which zsh)')


def configure_fish():
    if os.system('which -s fish') == '':
        os.system('brew install fish')
        os.system('curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish')
    os.system('chsh -s $(which fish)')


def configure_shell(name, additional):
    if additional:
        if name == 'fish':
            shell_answers = prompt(questions=questions.get_fish_additional_questions())
        else:
            shell_answers = prompt(questions=questions.get_zsh_additional_questions())
    if name == 'bash':
        configure_bash()
    elif name == 'zsh':
        configure_zsh()
    elif name == 'fish':
        configure_fish()


def install_cli(utils: list):
    for util in utils:
        if os.system('which -s {}'.format(util)) != 0:
            os.system("brew install -q {name}".format(name=util))
        else:
            print("{} already installed, Skipping...".format(util.capitalize()))


def install_casks(utils: list):
    casks_list = subprocess.check_output('brew list -1 --casks', shell=True).decode("utf-8").split()
    for cask in utils:
        if not casks_list.__contains__(cask):
            os.system("brew install -q --cask {name}".format(name=cask))
        else:
            print("{} already installed, Skipping...".format(cask.capitalize()))


def install(answers):
    configure_shell(answers.get('shell'), answers.get('shell_setup'))
    install_cli(answers.get('cli_utils'))
    install_casks(answers.get('casks'))
    # ###################
    # # Post Installation
    # ###################
    #
    # # Tmux Plugin Manager
    # git
    # clone
    # https: // github.com / tmux - plugins / tpm
    # ~ /.tmux / plugins / tpm
