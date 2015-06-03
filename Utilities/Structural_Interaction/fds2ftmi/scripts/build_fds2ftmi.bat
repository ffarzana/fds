
:: Firebot variables
set FIREBOT_DIR=%FDS_SVNROOT%/Utilities/Structural_Interaction/fds2ftmi/scripts
set FDS2FTMI_DIR=%FDS_SVNROOT%/Utilities/Structural_Interaction/fds2ftmi
set OUTPUT_DIR=%FDS2FTMI_DIR%/scripts/output
set ERROR_LOG=%OUTPUT_DIR%/errors
set WARNING_LOG=%OUTPUT_DIR%/warnings

:: Update Repository
set SVN_REVISION="%1"
echo %SVN_REVISION%
cd %FDS_SVNROOT%\FDS_Source
svn up -r %SVN_REVISION%


:: Clean outputs
cd %FIREBOT_DIR%
echo Y | del output

:: Create output dir
mkdir output

:: Clean previous results
cd %FDS2FTMI_DIR%/examples/simple_panel_hot
del *.csv 
cd %FDS2FTMI_DIR%/examples/h_profile
del *.csv 

:: Compile fds_win_64
cd %FDS_SVNROOT%/FDS_Compilation/intel_win_64
echo Y | make_fds.bat

:: Compile fds2ftmi_win_64
cd %FDS2FTMI_DIR%/intel_win_64
echo Y | make_fds2ascii.bat

:: Print the FDS revision number on User Guide
cd %FDS2FTMI_DIR%
sed -i "s:.*SVN Repository Revision.*:SVN Repository Revision %SVN_REVISION%:" fds2ftmi_user_guide.tex

:: Print the FDS revision number on python scripts
cd %FIREBOT_DIR%
sed -i "s:.*SVN=.*:SVN='%SVN_REVISION%':" generate_plots.py

:: Run Verification Cases
cd %FDS2FTMI_DIR%/examples/simple_panel_hot
call simple_panel_hot.bat
cd %FDS2FTMI_DIR%/examples/h_profile
call h_profile.bat

:: Run python scripts
cd %FIREBOT_DIR%
python generate_plots.py

:: Compile User Guide
cd %FDS2FTMI_DIR%
set TEXINPUTS=%TEXINPUTS%:.:../../../Manuals/LaTeX_Style_Files/
pdflatex fds2ftmi_user_guide.tex
bibtex fds2ftmi_user_guide
pdflatex fds2ftmi_user_guide.tex

:: Revert the FDS revision number on User Guide
cd %FDS2FTMI_DIR%
svn revert fds2ftmi_user_guide.tex
del sed*

:: Revert the FDS revision number on python scripts
cd %FIREBOT_DIR%
svn revert generate_plots.py
del sed*