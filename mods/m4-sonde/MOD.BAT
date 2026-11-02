@echo off
rem Avviare dalla junction games\crashbash-m4\mods\m4-sonde.
"C:\dev\crashbash-online-tools\psx-modding-toolchain\.venv\Scripts\python.exe" -I -c "import runpy,sys; from pathlib import Path; p=Path('../../../../tools/mod-builder/main.py').absolute(); sys.path.insert(0,str(p.parent)); sys.argv=[str(p),*sys.argv[1:]]; runpy.run_path(str(p),run_name='__main__')" %*
