@setlocal enableextensions

@echo off

echo.ant cio 100 2020.01 ada2fhir setup...
call ant -f _ant-buildfiles\ant-publish\build-ada2fhir-cio-100.xml setup >ant-setup.log

echo.Done
pause
