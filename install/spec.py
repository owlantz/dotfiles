# The dotfiles specification is a very customizable YAML file
# containing a list of programs and associated runtime configuration
# files and directories.  There are a variety of supported formats for
# each item, the most verbose case is outlined below:
#
# - <program>:
#   files:
#     - file_1
#     - file_2
#   depends:
#     - <program_1>
#     - <program_2>
#
# ~depends~ is optional, if <program> should be installed then <program_1>
# and <program_2> should be installed as well.  Otherwise dependency resolution
# is not used.
#
# files is also optional, a list of strings will be interpreted as files entries
#
# So, removing the depends 
#
# A list of files is also optional, a single string will be interpreted as
# a standalone file or directory that's associated with the program.
#
# For instance, emacs is specified as follows:
#
# - emacs: .emacs.d
#
# For a full example of the author's configuration, see the ~spec.yml~
# file in /script

def process(document):
    spec = { program: SpecItem(program, document) for program in document.keys() }

    _ensure_dependencies_exist(spec)

    return spec

def _ensure_dependencies_exist(spec):
    not_found = set()
    for entry in filter(lambda e: e.depends is not None, spec.values()):
        for d in entry.depends:
            if d not in spec:
                not_found.add(d)

    print(spec, not_found)
    if not_found:
        # TODO
        raise Exception()

    return True
    
        

class SpecItem:
    def __init__(self, program, spec):
        self.program = program
        self.files = None
        self.depends = None
        self._process(spec)

    def _process(self, spec):
        s = spec[self.program]

        match s:
            case str():
                self.files = [s]
                self.depends = None
            case list():
                self.f
                self.depends = None
            case dict():
                assert 'files' in s
                self.files = s['files']

                if 'depends' in s:
                    self.depends = s['depends']
                else:
                    self.depends = None

    def __repr__(self):
        return 'SpecItem<program={}, files={}, depends={}>'.format(
            self.program,
            self.files,
            self.depends)
