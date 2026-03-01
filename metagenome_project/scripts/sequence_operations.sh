#!/bin/bash


extract_fasta_headers() {
    local sequence_path="$1"

    if [ -f "$sequence_path" ]; then
        grep "^>" "$sequence_path"
        return 0
    else
        echo "File not found: $sequence_path"
        return 1
    fi
}


count_fasta_headers() {
    local sequence_path="$1"

    if [ -f "$sequence_path" ]; then
        grep -c "^>" "$sequence_path"
        return 0
    else
        echo "File not found: $sequence_path"
        return 1
    fi
}


get_genes() {
    local sequence_path="$1"
    if [ -f "$sequence_path" ]; then
        awk '$3 == "gene"' "$sequence_path" 
        return 0
    else
        echo "GTF file not found: $gsequence_path"
        return 1
    fi
}

sort_genes() {
    local sequence_path="$1"
    local sorting_columns="$2"
    if [ -f "$sequence_path" ]; then
        sort -k "$sorting_columns" "$sequence_path"
        return 0
    else
        echo "File not found: $sequence_path"
        return 1
    fi
}
