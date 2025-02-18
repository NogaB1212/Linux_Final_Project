#!/usr/bin/env bash
#
# q5_script.sh - Menu-based script for CSV operations (Question 5).
#
# Usage: ./q5_script.sh [CSV_FILE]
#   If CSV_FILE not provided, default is "specie.csv" in the current directory.
#
# Menu Options:
#  1. CREATE CSV by name
#  2. Display all CSV DATA with row INDEX
#  3. Read user input for new row
#  4. Read Species -> display items + average weight
#  5. Read Species & Sex -> display items
#  6. Save last output to new csv file
#  7. Delete row by index
#  8. Update weight by row index
#  9. Exit

OUTPUT_FILE="output_5.txt"
LAST_OUTPUT=".last_output.tmp"

# Create/clear these files at start
> "$OUTPUT_FILE"
> "$LAST_OUTPUT"

CSV_FILE="${1:-specie.csv}"

# Check if CSV exists; if not, we'll create on demand or exit
if [[ ! -f "$CSV_FILE" ]]; then
echo "[INFO] CSV file '$CSV_FILE' not found; some operations will require creation." | tee -a "$OUTPUT_FILE"
fi

# Helper Functions
function create_csv() {
read -p "Enter new CSV filename (e.g. mydata.csv): " new_csv
if [[ -z "$new_csv" ]]; then
 echo "No filename given. Returning to menu..." | tee -a "$OUTPUT_FILE"
 return
fi
if [[ -f "$new_csv" ]]; then
 echo "File '$new_csv' already exists!" | tee -a "$OUTPUT_FILE"
 return
fi
# Write a default header
echo "Date collected,Species,Sex,Weight" > "$new_csv"
echo "[INFO] Created '$new_csv' with default header." | tee -a "$OUTPUT_FILE"
}

function display_all_with_index() {
if [[ ! -f "$CSV_FILE" ]]; then
 echo "[ERROR] '$CSV_FILE' not found. Please create or specify a valid CSV." | tee -a "$OUTPUT_FILE"
 return
fi
echo "==== Displaying $CSV_FILE with row indexes ====" | tee -a "$OUTPUT_FILE"
i=0
# Print header separately
header=$(head -n 1 "$CSV_FILE")
echo "RowIndex,$header" | tee "$LAST_OUTPUT"

tail -n +2 "$CSV_FILE" | while IFS= read -r line; do
 echo "$i,$line" >> "$LAST_OUTPUT"
 ((i++))
done
cat "$LAST_OUTPUT" | tee -a "$OUTPUT_FILE"
}

function add_new_row() {
if [[ ! -f "$CSV_FILE" ]]; then
 echo "[ERROR] '$CSV_FILE' not found. Create it first or specify another CSV." | tee -a "$OUTPUT_FILE"
 return
fi
echo "Enter new row data (Format: Date collected,Species,Sex,Weight)"
read -p "Date collected: " date_col
read -p "Species: " species
read -p "Sex (M/F): " sex
read -p "Weight: " weight
echo "${date_col},${species},${sex},${weight}" >> "$CSV_FILE"
echo "[INFO] Added row: ${date_col},${species},${sex},${weight}" | tee -a "$OUTPUT_FILE"
}

function filter_by_species() {
read -p "Enter species (e.g., OT, PF, NA): " sp
if [[ -z "$sp" ]]; then
 echo "No species entered. Returning..." | tee -a "$OUTPUT_FILE"
 return
fi
if [[ ! -f "$CSV_FILE" ]]; then
 echo "[ERROR] '$CSV_FILE' not found. Cannot filter." | tee -a "$OUTPUT_FILE"
 return
fi

# Filter lines matching that species
header=$(head -n1 "$CSV_FILE")
echo "$header" > "$LAST_OUTPUT"
tail -n +2 "$CSV_FILE" | grep ",${sp}," >> "$LAST_OUTPUT" || true

# Calculate average weight
total=0
count=0
while IFS=',' read -r _ species sex weight; do
 # skip if not the right species
 # (We already grep, so this might be redundant, but let's be safe)
 if [[ "$species" == "$sp" ]]; then
   total=$(awk -v t=$total -v w=$weight 'BEGIN {print t + w}')
   ((count++))
 fi
done < <(tail -n +2 "$CSV_FILE")

echo "==== Filter results for species: $sp ====" | tee -a "$OUTPUT_FILE"
cat "$LAST_OUTPUT" | tee -a "$OUTPUT_FILE"

if [[ $count -gt 0 ]]; then
 avg=$(awk -v t=$total -v c=$count 'BEGIN {print t / c}')
 echo "Average weight for $sp: $avg" | tee -a "$OUTPUT_FILE"
else
 echo "No entries found for species: $sp" | tee -a "$OUTPUT_FILE"
fi
}

function filter_by_species_sex() {
read -p "Enter species (e.g. OT, PF, NA): " sp
read -p "Enter sex (M/F): " sx

if [[ -z "$sp" || -z "$sx" ]]; then
 echo "Species or Sex not provided." | tee -a "$OUTPUT_FILE"
 return
fi
if [[ ! -f "$CSV_FILE" ]]; then
 echo "[ERROR] '$CSV_FILE' not found. Cannot filter." | tee -a "$OUTPUT_FILE"
 return
fi

header=$(head -n1 "$CSV_FILE")
echo "$header" > "$LAST_OUTPUT"
tail -n +2 "$CSV_FILE" | grep ",${sp},${sx}," >> "$LAST_OUTPUT" || true

echo "==== Filter results for Species: $sp, Sex: $sx ====" | tee -a "$OUTPUT_FILE"
cat "$LAST_OUTPUT" | tee -a "$OUTPUT_FILE"
}

function save_last_output() {
read -p "Enter new CSV filename to save last output: " newfile
if [[ -z "$newfile" ]]; then
 echo "No file name provided. Aborting." | tee -a "$OUTPUT_FILE"
 return
fi
if [[ ! -s "$LAST_OUTPUT" ]]; then
 echo "No last output to save or file empty." | tee -a "$OUTPUT_FILE"
 return
fi
cp "$LAST_OUTPUT" "$newfile"
echo "[INFO] Last output saved to '$newfile'." | tee -a "$OUTPUT_FILE"
}

function delete_by_index() {
if [[ ! -f "$CSV_FILE" ]]; then
 echo "[ERROR] '$CSV_FILE' not found. Cannot delete." | tee -a "$OUTPUT_FILE"
 return
fi
display_all_with_index  # This will populate $LAST_OUTPUT with row-index data
read -p "Enter row index to delete: " idx

# Rebuild the file except the chosen row
header=$(head -n1 "$CSV_FILE")
echo "$header" > .temp.csv

# row-based approach
i=0
tail -n +2 "$CSV_FILE" | while IFS= read -r line; do
 if [[ $i -ne $idx ]]; then
   echo "$line" >> .temp.csv
 fi
 ((i++))
done

mv .temp.csv "$CSV_FILE"
echo "[INFO] Row $idx deleted from $CSV_FILE (if it existed)." | tee -a "$OUTPUT_FILE"
}

function update_weight_by_index() {
if [[ ! -f "$CSV_FILE" ]]; then
 echo "[ERROR] '$CSV_FILE' not found. Cannot update." | tee -a "$OUTPUT_FILE"
 return
fi
display_all_with_index
read -p "Enter row index to update weight: " idx
read -p "Enter new weight: " new_w

header=$(head -n1 "$CSV_FILE")
echo "$header" > .temp.csv

i=0
tail -n +2 "$CSV_FILE" | while IFS=',' read -r date_col species sex weight; do
 if [[ $i -eq $idx ]]; then
   echo "${date_col},${species},${sex},${new_w}" >> .temp.csv
 else
   echo "${date_col},${species},${sex},${weight}" >> .temp.csv
 fi
 ((i++))
done

mv .temp.csv "$CSV_FILE"
echo "[INFO] Updated row $idx with new weight = $new_w" | tee -a "$OUTPUT_FILE"
}

# Main Menu Loop
while true; do
echo ""
echo "============= Q5 MENU ============="
echo "1) CREATE CSV by name"
echo "2) Display all CSV DATA with row INDEX"
echo "3) Read user input for new row"
echo "4) Read Species -> display items + average weight"
echo "5) Read Species & Sex -> display items"
echo "6) Save last output to new csv file"
echo "7) Delete row by index"
echo "8) Update weight by row index"
echo "9) Exit"
echo "==================================="
read -p "Choose an option [1-9]: " opt

case "$opt" in
 1) create_csv ;;
 2) display_all_with_index ;;
 3) add_new_row ;;
 4) filter_by_species ;;
 5) filter_by_species_sex ;;
 6) save_last_output ;;
 7) delete_by_index ;;
 8) update_weight_by_index ;;
 9) echo "Exiting..." | tee -a "$OUTPUT_FILE"; break ;;
 *) echo "Invalid option. Please choose [1-9]." | tee -a "$OUTPUT_FILE" ;;
esac
done

exit 0