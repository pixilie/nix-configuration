import os
import subprocess
import re
import sys

login = "kristen.couty"

def format_tp_name(tp_name):
    formatted_tp_name = ""
    split_tp_name = re.findall('[A-Z][^A-Z]*', tp_name)

    for elt in split_tp_name:
        formatted_tp_name += elt[0].lower() + elt[1:] + "-"

    return formatted_tp_name[:-1]

def get_repository_name(repository_link):
    return repository_link[len(login) + 70:-4]
    
def format_repository_name(repository_name, parsed_tp_name):
    formatted_repository_name = ""
    formatted_repository_name += repository_name[29:48]
    formatted_repository_name += parsed_tp_name  
    return formatted_repository_name
    
def main():
    tp_name = sys.argv[1]
    repository_link = sys.argv[2]
    is_school = sys.argv[3]

    if is_school == "true":
        tp_directory = "/home/kristen.couty/afs/practicals"
    else:
        tp_directory = "/home/kristen/documents/epita/spe/programmation/"
    
    formatted_tp_name = format_tp_name(tp_name)
    repository_name = get_repository_name(repository_link)
    formatted_repository_name = format_repository_name(repository_name, formatted_tp_name)

    # Clone and rename repository
    os.chdir(tp_directory)
    subprocess.run(["git", "clone", repository_link])
    os.rename(f"{repository_name}", f"{formatted_repository_name}")
    os.chdir(formatted_repository_name)
    subprocess.run(["git", "switch", "-c" "master"])      

    # Create basics repo files
    with open(".gitignore", "w") as gitignore:
        gitignore.write("*.a\n*.lib\n*.o\n*.obj\n*.out\n.idea/\n*~\n*.DotSettings.user")

    with open("README", "w") as readme:
        readme.write(f"# {tp_name}")

    with open("AUTHORS", "w") as readme:
        readme.write("Kristen\nCouty\nkristen.couty\nkristen.couty@epita.fr")

    print(f"Succesfully initialized {tp_name}")
    
if __name__ == "__main__":
    main()
