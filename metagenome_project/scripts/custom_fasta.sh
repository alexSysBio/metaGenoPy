#!/bin/bash

cd ..
echo "Creating directory for custom FASTA files..."
DESTINATION_DIR="custom_fasta_data/"
mkdir -p "$DESTINATION_DIR"
echo ""

echo "Choose a name for the fasta file:"
read fasta_file_name
fasta_file_name=${fasta_file_name%$'\r'}
echo ""

echo "Creae and edit the FASTA file at: ${DESTINATION_DIR}${fasta_file_name}.fasta"
touch "${DESTINATION_DIR}${fasta_file_name}.fasta"
if [ -f "${DESTINATION_DIR}${fasta_file_name}.fasta" ]; then
    echo "File exists and will be edited..."
    nano "${DESTINATION_DIR}${fasta_file_name}.fasta"
else
    echo "A new file is being created."
    nano "${DESTINATION_DIR}${fasta_file_name}.fasta"
fi

