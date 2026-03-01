
#!/bin/bash
. ./sequence_operations.sh

# Get the directory where this script is located.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# The project root is one level up from the scripts directory.
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")


echo "--- Starting the main bioinformatics workflow ---"
echo ""

echo "Step 1: Creating project structure..."
# Use the PROJECT_ROOT variable to build absolute paths
mkdir -p "${PROJECT_ROOT}/genome_data"
rm -f last_run.info
echo ""

echo "Step 2: Downloading genome data..."
# This call works because both scripts are in the same 'scripts' folder.
# The SCRIPT_DIR makes sure it runs correctly from anywhere.
echo "Select a genome to download by entering its accession number (e.g., GCA_000146045.2 for Yeast):"
genome_data=$(${SCRIPT_DIR}/download_genome_directory.sh)
# Extract the accession number and genome directory from the output.
IFS=',' read -r ACCESSION GENOME_DIR < "${PROJECT_ROOT}/last_run.info"
echo "Downloaded genome data for accession: $ACCESSION"
echo "Genome data directory: $GENOME_DIR"
echo ""

# echo "Step 3: Accessing gene information and count genes..."
CDS_FILE="${PROJECT_ROOT}/${GENOME_DIR}/cds_from_genomic.fna"
cds_seq_count=$(count_fasta_headers "$CDS_FILE")

echo "Number of CDS sequences: $cds_seq_count for accession number: $ACCESSION"
(extract_fasta_headers "$CDS_FILE") > "${PROJECT_ROOT}/${GENOME_DIR}/cds_headers.txt"
echo "First 10 CDS headers:"
head -n 10 "${PROJECT_ROOT}/${GENOME_DIR}/cds_headers.txt"
echo ""

GFF_FILE="${PROJECT_ROOT}/${GENOME_DIR}/genomic.gff"
echo "Extracting gene features from GFF..."
(get_genes "$GFF_FILE") > "${PROJECT_ROOT}/${GENOME_DIR}/genes_only.gff"
echo "First 10 gene features:"
head -n 10 "${PROJECT_ROOT}/${GENOME_DIR}/genes_only.gff"

# This line seems to be for sorting, which is fine.
(sort_genes "${PROJECT_ROOT}/${GENOME_DIR}/cds_headers.txt" "2,2") > "${PROJECT_ROOT}/${GENOME_DIR}/sorted_cds_headers.txt"