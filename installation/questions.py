import json

with open('installation/casks.json') as json_file:
    casks = json.load(json_file)
with open('installation/cli_utils.json') as json_file:
    cli_utils = json.load(json_file)


def get_choices_from_file(items: list):
    choices = []
    for item in items:
        choices.append({
            'name': item
        })
    return choices


def get_zsh_additional_questions():
    return [
        {
            'type': 'confirm',
            'name': 'omz',
            'message': 'Do you want to install Oh My Zsh?',
            'default': True
        }
    ]


def get_fish_additional_questions():
    return [
        {
            'type': 'confirm',
            'name': 'omf',
            'message': 'Do you want to install Oh My Fish?',
            'default': True
        }
    ]


def get_questions():
    return [
        {
            'type': 'list',
            'name': 'shell',
            'message': "What shell do you want to use as Default?",
            'choices': ['Bash', 'ZSH', 'Fish'],
            'default': 'fish',
            'filter': lambda val: val.lower()   # type: str
        },
        {
            'type': 'confirm',
            'name': 'shell_setup',
            'message': 'Do you want to setup Shell Environment?',
            'default': True
        },
        {
            'type': 'checkbox',
            'name': 'cli_utils',
            'message': 'What CLI apps do you need to install?',
            'choices': get_choices_from_file(cli_utils)
        },
        {
            'type': 'checkbox',
            'name': 'casks',
            'message': 'What Applications do you need to install?',
            'choices': get_choices_from_file(casks)
        }
    ]
