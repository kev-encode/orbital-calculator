import os
import sys
import PySide6

# note: Qt plugin loader ignores PATH on Windows; PySide6 dir must be DLL search dir
if sys.platform == "win32":
    import ctypes

    os.add_dll_directory(os.path.dirname(PySide6.__file__))
    # note: own taskbar identity, else Windows groups the app under python.exe and shows its icon
    ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID("orbital-calculator")

from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    app.setWindowIcon(QIcon(os.path.join(sys.path[0], "app", "icon.svg")))

    engine = QQmlApplicationEngine()
    engine.addImportPath(sys.path[0])
    engine.loadFromModule("app", "Main")

    if not engine.rootObjects():
        sys.exit(-1)

    exit_code = app.exec()
    del engine
    sys.exit(exit_code)