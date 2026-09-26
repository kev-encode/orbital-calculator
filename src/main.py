import os
import sys
import PySide6

# note: Qt plugin loader ignores PATH on Windows; PySide6 dir must be DLL search dir
if sys.platform == "win32":
    os.add_dll_directory(os.path.dirname(PySide6.__file__))

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)

    engine = QQmlApplicationEngine()
    engine.addImportPath(sys.path[0])
    engine.loadFromModule("app", "Main")

    if not engine.rootObjects():
        sys.exit(-1)

    exit_code = app.exec()
    del engine
    sys.exit(exit_code)