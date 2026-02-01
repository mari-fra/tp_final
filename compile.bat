@echo off
REM Batch script to compile LaTeX report on Windows
REM This replaces the Makefile functionality for Windows users

REM Ensure MiKTeX is on PATH (Cursor's terminal may not inherit it)
set "MIKTEX_BIN="
if exist "%LOCALAPPDATA%\Programs\MiKTeX\miktex\bin\x64\pdflatex.exe" set "MIKTEX_BIN=%LOCALAPPDATA%\Programs\MiKTeX\miktex\bin\x64"
if not defined MIKTEX_BIN if exist "%ProgramFiles%\MiKTeX\miktex\bin\x64\pdflatex.exe" set "MIKTEX_BIN=%ProgramFiles%\MiKTeX\miktex\bin\x64"
if defined MIKTEX_BIN set "PATH=%MIKTEX_BIN%;%PATH%"

echo === Creating build directory ===
if not exist build mkdir build

echo === First pass ===
pdflatex -output-directory=build -interaction=nonstopmode -file-line-error report.tex

echo === Second pass (resolve references) ===
pdflatex -output-directory=build -interaction=nonstopmode -file-line-error report.tex

echo === Third pass (final references) ===
pdflatex -output-directory=build -interaction=nonstopmode -file-line-error report.tex

echo === Moving PDF to root ===
if exist build\report.pdf (
    copy build\report.pdf report.pdf
    echo === Compilation complete: report.pdf ===
) else (
    echo === Error: PDF not generated. Check build\report.log for errors ===
)

pause
