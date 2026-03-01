
#!/bin/bash


cd ..
DESTINATION_DIR="genome_data/"

echo "--- NCBI Interactive Data Downloader with Validation ---"
while true; do
  echo ""
  echo -n "Please enter NCBI accession (or type STOP/press Enter to exit): "
  read accession_number
  
  accession_number=${accession_number%$'\r'}

  if [[ "${accession_number^^}" == "STOP" || -z "$accession_number" ]]; then
    echo "Exit condition met. Terminating script."
    exit 0
  fi

  echo "Validating accession '$accession_number' with NCBI..."
  http_status=$(curl -s -o /dev/null -w '%{http_code}' "https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/${accession_number}/summary")

  if [ "$http_status" -eq 200 ]; then
    echo "Accession is VALID. Proceeding to download."
    break 
  else
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "ERROR: Invalid or non-existent accession (Server code: $http_status)."
    echo "Please try again."
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  fi
done

# --- Download and Validation Section ---

echo ""
# This version requests GFF3, which is almost always available.
URL="https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/${accession_number}/download?include_annotation_type=GENOME_FASTA&include_annotation_type=GENOME_GFF&include_annotation_type=RNA_FASTA&include_annotation_type=CDS_FASTA&include_annotation_type=PROT_FASTA&include_annotation_type=SEQUENCE_REPORT&hydrated=FULLY_HYDRATED"
OUTPUT_FILE="${DESTINATION_DIR}${accession_number}.zip"

mkdir -p "$DESTINATION_DIR"

echo "Downloading from: $URL"
curl -L -o "$OUTPUT_FILE" "$URL"

# Check if the file was created.
if [ -f "$OUTPUT_FILE" ]; then
  # Now, check if the created file is a valid zip archive.
  if unzip -t "$OUTPUT_FILE" &>/dev/null; then
      echo "Download complete. Unzipping..."
      unzip -o "$OUTPUT_FILE" -d "$DESTINATION_DIR"
      echo "Unzip complete."
      echo "Cleaning up the downloaded zip file..."
      rm "$OUTPUT_FILE"
  else
      # --- THIS IS THE NEW CLEANUP LOGIC ---
      echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      echo "ERROR: Downloaded file is not a valid zip archive. It may be an error message."
      echo "Cleaning up the invalid file: $OUTPUT_FILE"
      rm "$OUTPUT_FILE" # Delete the bad file.
      echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      exit 1 # Exit with an error code.
  fi
else
  # This block runs if curl failed to create any file at all.
  echo "ERROR: Download failed. The file '$OUTPUT_FILE' was not created."
  exit 1
fi

echo ""
echo "--- Script finished successfully! ---"
GENOME_DIR="${DESTINATION_DIR}ncbi_dataset/data/${accession_number}" 
echo "${accession_number},${GENOME_DIR}" > last_run.info
exit 0

