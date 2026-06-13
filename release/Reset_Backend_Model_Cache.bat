@echo off
echo Resetting Sleep Quality model cache...
cd /d "%~dp0backend"
if exist data\sleep_energy_model.joblib del /f /q data\sleep_energy_model.joblib
for %%f in (data\sleep_energy_model.invalid_*.joblib) do del /f /q "%%f"
echo Done. Start the backend again to retrain a fresh model.
pause
