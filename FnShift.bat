@ECHO OFF
SET "Input_Count=%~1"

FOR /L %%I IN (1,1,%Input_Count%) DO SHIFT
