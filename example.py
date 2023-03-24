def secure_importer(name, globals=None, locals=None, fromlist=(), level=0):
  raise ImportError("module '%s' is restricted."%name)

__builtins__.__dict__['__import__'] = secure_importer

import A
