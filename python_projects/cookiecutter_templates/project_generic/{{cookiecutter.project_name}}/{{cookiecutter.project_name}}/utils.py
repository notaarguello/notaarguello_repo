import os
import re
import yaml

from typing import Optional, Generator, Any


_compiled_regex_dict = {}

def _update_compiled_regexes(regex_list: list[str]):
    """
    Compiles regex patterns and stores them in the global dictionary if they are not already compiled.
    This function is intended for internal use within this module.
    """
    for pattern in regex_list:
        if pattern not in _compiled_regex_dict:
            _compiled_regex_dict[pattern] = re.compile(pattern)


def matches_any_regex(s: Optional[str], regex_list: list[str]) -> bool:
    """
    Checks if the string matches any of the provided regex patterns using pre-compiled patterns for performance.
    """
    if s:
        # Ensure all regexes in the list are compiled and stored in the global dictionary
        _update_compiled_regexes(regex_list)
        
        # Use the compiled regex patterns for matching
        return any(_compiled_regex_dict[pattern].search(s) for pattern in regex_list)
    return False


def create_path_if_not_exists(path: str) -> str:
    """
    Creates a directory at the specified path if it does not already exist.

    Args:
    path (str): The path of the directory to be created.

    Returns:
    str: The path of the directory.
    """
    if not os.path.exists(path):
        os.makedirs(path)
    return path


def parse_array_env_var(env_var_name:str) -> list:
    return os.getenv(env_var_name, "").split(" ") if os.getenv(env_var_name) else []


def read_file_contents(file_full_path:str) -> Optional[str]:
    try:
        with open(file_full_path, 'r') as file:
            return file.read()
    except FileNotFoundError:
        return "File not found."
    except Exception as e:
        return f"An error occurred: {e}"


def walk_dir(dir_to_walk: str, recursive: bool = False) -> Generator[tuple[str, str], None, None]:
    if recursive:
        for root, _, files in os.walk(dir_to_walk):
            for filename in files:
                yield (root, filename)
    else:
        for filename in os.listdir(dir_to_walk):
            yield (dir_to_walk, filename)


class IndentedYamlDumper(yaml.Dumper):

    def increase_indent(self, flow=False, indentless=False):
        return super(IndentedYamlDumper, self).increase_indent(flow, False)
    

def yaml_pretty_dump(s: dict[Any, Any]) -> str:
    return yaml.dump(s, Dumper=IndentedYamlDumper, default_flow_style=False, default_style=None)