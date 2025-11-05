# MRSA Diagnostic qPCR Primer Design Pipeline

This project details a fully reproducible bioinformatics pipeline used to design highly specific, conserved $\text{qPCR}$ primers and $\text{TaqMan}$ probes for the detection of the **$\text{mecA}$ gene** ($\text{MRSA}$ status) and the **$\text{nucA}$ gene** (*Staphylococcus aureus* confirmation).

## 🚀 Workflow Overview

The pipeline automates the following steps using command-line tools ($\text{bedtools}$, $\text{Clustal}$ $\text{O}$, $\text{EMBOSS}$, $\text{Primer3}$):

1.  **Gene Extraction:** Extract $\text{mecA}$ and $\text{nucA}$ coding sequences from $\text{MRSA}$ ($\text{N315}$) and $\text{MSSA}$ ($\text{MSSA-47}$) reference genomes using $\text{FASTA}$ and $\text{GTF}$ files.
2.  **Sequence Alignment:** Perform Multiple Sequence Alignment ($\text{MSA}$) to identify **conserved regions** across both strains.
3.  **Consensus Generation:** Generate a consensus sequence from the alignment to ensure **broad strain coverage** for primer binding.
4.  **Primer/Probe Design:** Use $\text{Primer3}$ to design optimal primer pairs (Product size: $\text{50-52 bp}$, $\text{T}_{\text{m}}: \sim 60^{\circ}\text{C}$) and $\text{TaqMan}$ probes.

## 🔬 Final Designed Sequences

| Gene | Component | Sequence (5' to 3') | Product Size ($\text{bp}$) | $\text{T}_{\text{m}}$ ($\text{avg}^{\circ}\text{C}$) |
| :--- | :--- | :--- | :--- | :--- |
| **$\text{mecA}$** | **Forward Primer** | `cAaAAGTTtCAggTGcgc` | 51 | 55.4 |
| | **Reverse Primer** | `aTTgcgcacCtTcAtttG` | | 54.4 |
| | **Probe** | `TGCTTTGGTCTTTCTGCATTCCTGG` | N/A | 57.9 |
| **$\text{nucA}$** | **Forward Primer** | `GTGAAGCAGGATCAGCAGGT` | 297 | 60.0 |
| | **Reverse Primer** | `GCGCTTGGAAATCCGTACAG` | | 59.6 |
| | **Probe** | `AGTTAGGTTTACCATACCGTCGTGT` | N/A | 55.8 |

## ⚙️ How to Run the Pipeline

### Prerequisites

You must have the following tools installed (ideally within a single $\text{Conda}$ environment):
* `bash` (Ubuntu/Linux)
* `bedtools`
* `clustalo`
* `emboss` (for $\text{cons}$ and $\text{extractseq}$)
* `primer3`

### Execution

1.  Clone this repository.
2.  Ensure the necessary input files (`*.fna`, `*.gtf`) are placed in the **`input_data/`** directory.
3.  Make the script executable: `chmod +x scripts/run_primer_design.sh`
4.  Run the pipeline: `./scripts/run_primer_design.sh`
