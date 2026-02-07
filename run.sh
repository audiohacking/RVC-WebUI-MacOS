#!/bin/sh

set -fa

# Check if Python is installed
if ! command -v python; then
  echo "Python not found. Please install Python using your package manager or via PyEnv."
  exit 1
fi

requirements_file="requirements/main.txt"
venv_path=".venv"

# Parse command line arguments
download_models=false
for arg in "$@"; do
  case $arg in
    --download-models)
      download_models=true
      shift
      ;;
    *)
      ;;
  esac
done

if [[ ! -d "${venv_path}" ]]; then
  echo "Creating venv..."

  python -m venv "${venv_path}"
  source "${venv_path}/bin/activate"

  # Check if required packages are up-to-date
  pip install --upgrade -r "${requirements_file}"
fi
echo "Activating venv..."
source "${venv_path}/bin/activate"

# Download models if requested
if [ "$download_models" = true ]; then
  echo ""
  echo "Running model downloader..."
  python download_models.py
  download_exit_code=$?
  
  if [ $download_exit_code -eq 0 ]; then
    echo ""
    echo "Models are ready!"
  else
    echo ""
    echo "Note: Model download completed with warnings."
    echo "The application will still start."
  fi
  
  echo ""
  read -p "Press Enter to continue and start the application..."
  echo ""
fi

# Run the main script
echo "Starting RVC WebUI..."
python web.py --pycmd python
