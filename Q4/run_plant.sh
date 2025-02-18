#!/bin/bash

# Define variables
REPO_DIR="$(pwd)"  # Current repository directory
VENV_DIR="$HOME/venv_Q4"  # Virtual environment outside the repository
CSV_FILE="${1:-plants.csv}"
PYTHON_SCRIPT="plant_improve.py"
LOG_FILE="execution_log.txt"

# Ensure virtual environment exists
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment in $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
fi

# Activate virtual environment
source "$VENV_DIR/bin/activate"

# Install necessary libraries if missing
pip install --upgrade pip > /dev/null 2>&1
pip install pandas matplotlib argparse > /dev/null 2>&1

# Return to repository
cd "$REPO_DIR"

# Read CSV and execute Python script for each row
tail -n +2 "$CSV_FILE" | while IFS=, read -r plant height leaf_count dry_weight; do
    # Clean up values
    plant_clean=$(echo "$plant" | tr -d '"' | tr ' ' '_')
    height_clean=$(echo "$height" | tr -d '"' | tr -s ' ')
    leaf_count_clean=$(echo "$leaf_count" | tr -d '"' | tr -s ' ')
    dry_weight_clean=$(echo "$dry_weight" | tr -d '"' | tr -s ' ')

    # Debug output
    echo "Creating directory for plant: '$plant_clean'"
    echo "Cleaned Height: $height_clean"
    echo "Cleaned Leaf Count: $leaf_count_clean"
    echo "Cleaned Dry Weight: $dry_weight_clean"

    # Ensure the plant directory is inside Q4/
    plant_dir="Q4/$plant_clean"
    mkdir -p "$plant_dir"

    # Verify directory creation
    if [ -d "$plant_dir" ]; then
        echo "Directory created successfully: $plant_dir"
    else
        echo "Error: Failed to create directory for $plant_clean"
        exit 1
    fi

    # Run Python script with the correct --plant argument
    echo "Running Python script for $plant_clean..."
    python3 "$PYTHON_SCRIPT" --plant "$plant_clean" --height $height_clean --leaf_count $leaf_count_clean --dry_weight $dry_weight_clean >> "$LOG_FILE" 2>&1

    # Check success of script execution
    if [ $? -eq 0 ]; then
        echo "Execution successful for $plant_clean"
    else
        echo "Error running script for $plant_clean, check $LOG_FILE for details"
    fi
done
