@setlocal enableextensions

@echo off

echo.ant ada2hl7 MP 9 2.0 build...
call ant -f _ant-buildfiles\ant-publish\build-ada2hl7-mp-920.xml >ant-build.log

echo.Done
pause
