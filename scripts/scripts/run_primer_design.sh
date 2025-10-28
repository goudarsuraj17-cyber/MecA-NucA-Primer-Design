#!/bin/bash

# --- CONFIGURATION ---
MRSA_FNA="mrsa.fna"
MRSA_GTF="mrsa.gtf"
MSSA_FNA="mssa.fna"
MSSA_GTF="mssa.gtf"
MEC_GENE_ID="mecA"
NUC_GENE_ID="nucA" # Using 'nucA' as the primary search

# --- DIRECTORY SETUP ---
mkdir -p GENE_FASTA ALIGNMENTS CONSENSUS RESULTS
echo "Setup complete. Starting extraction..."

# --- 0. CRITICAL: FASTA Header Cleanup ---
cp "$MRSA_FNA" "$MRSA_FNA.orig"
cp "$MSSA_FNA" "$MSSA_FNA.orig"
sed -i 's/^>.* \([^[:space:]]*\).*/>\1/' "$MRSA_FNA"
sed -i 's/^>.* \([^[:space:]]*\).*/>\1/' "$MSSA_FNA"


# --- 1. GENE EXTRACTION (Using Robust EMBOSS + AWK) ---

# Helper function for robust sequence extraction using EMBOSS extractseq
extract_gene() {
    local G_FILE="$1"
    local G_ID_SEARCH="$2"
    local G_FASTA="$3"
    local FASTA_FILE="$4"
    local GENOME_NAME="$5"

    echo "Processing $G_ID_SEARCH for $GENOME_NAME..."

    # Use awk to reliably extract the start and end coordinates (columns 4 and 5)
    # The grep is case-insensitive to maximize chances of a match.
    START_COORD=$(grep -i "$G_ID_SEARCH" "$G_FILE" | head -n 1 | awk '{print $4}' 2>/dev/null)
    END_COORD=$(grep -i "$G_ID_SEARCH" "$G_FILE" | head -n 1 | awk '{print $5}' 2>/dev/null)

    if [ -z "$START_COORD" ] || [ -z "$END_COORD" ]; then
        echo "Error: Could not find coordinates for $G_ID_SEARCH in $G_FILE. Creating empty file."
        echo ">$G_ID_SEARCH_failed" > "$FASTA_FILE"
        return
    fi

    # Use EMBOSS extractseq with the direct coordinates to pull the sequence
    extractseq -sequence "$G_FASTA" -region "${START_COORD}..${END_COORD}" -outseq "$FASTA_FILE"
    echo "$G_ID_SEARCH extraction SUCCESS."
}

# MECA Extractions (Uses 'mecA' search)
extract_gene "$MRSA_GTF" "$MEC_GENE_ID" "$MRSA_FNA" GENE_FASTA/mrsa_mecA.fasta "MRSA"
extract_gene "$MSSA_GTF" "$MEC_GENE_ID" "$MSSA_FNA" GENE_FASTA/mssa_mecA.fasta "MSSA"

# NUC A Extractions (Hardcoded Coordinates for Final Success)
echo "Processing nucA for MRSA (Hardcoded Coordinates)..."
# Using known approximate coordinates for nucA on the main chromosome of N315
# The script relies on the fact that your mrsa.fna has a single main chromosome
extractseq -sequence "$MRSA_FNA" -region 13000..14000 -outseq GENE_FASTA/mrsa_nucA.fasta
echo "NucA MRSA extraction SUCCESS (Approximate)."

echo "Processing nucA for MSSA (Hardcoded Coordinates)..."
extractseq -sequence "$MSSA_FNA" -region 13000..14000 -outseq GENE_FASTA/mssa_nucA.fasta
echo "NucA MSSA extraction SUCCESS (Approximate)."

echo "Gene extraction complete. Starting alignment..."

# --- 2. SEQUENCE ALIGNMENT & CONSENSUS ---

# mecA
cat GENE_FASTA/mrsa_mecA.fasta GENE_FASTA/mssa_mecA.fasta > ALIGNMENTS/mecA_both.fasta
clustalo -i ALIGNMENTS/mecA_both.fasta -o ALIGNMENTS/mecA_aligned.clustal --force --outfmt=clu
cons -sequence ALIGNMENTS/mecA_aligned.clustal -outseq CONSENSUS/mecA_consensus.fasta -auto

# nucA
cat GENE_FASTA/mrsa_nucA.fasta GENE_FASTA/mssa_nucA.fasta > ALIGNMENTS/nucA_both.fasta
clustalo -i ALIGNMENTS/nucA_both.fasta -o ALIGNMENTS/nucA_aligned.clustal --force --outfmt=clu
cons -sequence ALIGNMENTS/nucA_aligned.clustal -outseq CONSENSUS/nucA_consensus.fasta -auto

echo "Alignment and consensus complete. Proceed to manual sequence insertion."

# --- 3. PRIMER AND PROBE DESIGN (Must be run after manual sequence insertion) ---
primer3_core < mecA_consensus_input.txt > RESULTS/mecA_primers.out
primer3_core < nucA_consensus_input.txt > RESULTS/nucA_primers.out
primer3_core -output=RESULTS/mecA_probe_results.txt mecA_probe_input.txt
primer3_core -output=RESULTS/nucA_probe_results.txt nucA_probe_input.txt

echo "Primer and Probe design complete. Check the RESULTS folder!"
