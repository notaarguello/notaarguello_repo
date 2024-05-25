import os
import re
import yaml
import shutil
import datetime

from typing import Optional, Generator, Any, Callable


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


def parse_array_env_var(env_var_name:str) -> list:
    return os.getenv(env_var_name, "").split(" ") if os.getenv(env_var_name) else []


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


def read_file_contents(file_full_path:str) -> Optional[str]:
    try:
        with open(file_full_path, 'r') as file:
            return file.read()
    except FileNotFoundError:
        return "File not found."
    except Exception as e:
        return f"An error occurred: {e}"


def write_content_to_file(file_full_path: str, content: str, mode: str = 'a') -> None:
    try:
        if mode not in ['w', 'a']:
            raise ValueError("Mode must be 'w' for overwrite or 'a' for append.")
        with open(file_full_path, mode) as file:
            file.write(content)
    except Exception as e:
        print(f"Failed to write to {file_full_path}: {e}")


def walk_dir(dir_to_walk: str, recursive: bool = False) -> Generator[tuple[str, str], None, None]:
    if recursive:
        for root, _, files in os.walk(dir_to_walk):
            for filename in files:
                yield (root, filename)
    else:
        for filename in os.listdir(dir_to_walk):
            yield (dir_to_walk, filename)


def process_files(dir_to_walk: str, filename_regex: str, process_function: Callable[[str], str], 
                  mode: str = 'a',  make_backup: bool = False) -> None:
    
    if make_backup:
        # Generate a timestamp for the backup directory
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        backup_dir = f"{dir_to_walk}_bk{timestamp}"
        shutil.copytree(dir_to_walk, backup_dir)

    walker = walk_dir(dir_to_walk=dir_to_walk, recursive=True)
    pattern = re.compile(filename_regex)

    for root, filename in walker:
        if pattern.match(filename):
            full_path = os.path.join(root, filename)
            content = read_file_contents(file_full_path=full_path)
            if content is not None:  # Only process if file is read successfully
                new_content = process_function(content)
                write_content_to_file(file_full_path=full_path, content=new_content, mode=mode)


class IndentedYamlDumper(yaml.Dumper):

    def increase_indent(self, flow=False, indentless=False):
        return super(IndentedYamlDumper, self).increase_indent(flow, False)
    

def yaml_pretty_dump(s: dict[Any, Any]) -> str:
    return yaml.dump(s, Dumper=IndentedYamlDumper, default_flow_style=False, default_style=None)