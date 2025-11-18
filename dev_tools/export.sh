#!/bin/bash
set -e

# --- Configuration ---
cd "$(dirname "$0")/.."

PROJECT_ROOT=$(pwd)
OUTPUT_FILE="${PROJECT_ROOT}/project_export.txt"

# --- Initial Setup ---
echo "--- Project Export ---" > "$OUTPUT_FILE"
echo "Generated: $(date)" >> "$OUTPUT_FILE"

# --- GCP IAM Export ---
echo "Attempting to export GCP IAM policy..."
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
    echo "WARNING: GCP Project ID not found. Skipping IAM export."
    echo "         (To fix, run 'gcloud auth login' and 'gcloud config set project YOUR_PROJECT_ID')"
else
    echo "Exporting IAM policy for project: ${PROJECT_ID}"
    
    echo "" >> "$OUTPUT_FILE"
    echo "======================================================================" >> "$OUTPUT_FILE"
    echo "GCP IAM POLICY (Principals & Roles) | Project: ${PROJECT_ID}" >> "$OUTPUT_FILE"
    echo "======================================================================" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    gcloud projects get-iam-policy "${PROJECT_ID}" --format="yaml" >> "$OUTPUT_FILE"
fi

# --- Project Code Export ---
echo "Exporting project code structure to ${OUTPUT_FILE}..."

find . \( \
    -name ".git" -o \
    -name ".venv" -o \
    -name "venv" -o \
    -name ".vscode" -o \
    -name ".idea" -o \
    -name "__pycache__" -o \
    -path "./web-app/node_modules" -o \
    -path "./web-app/build" \
\) -prune -o \
-type f \
-not -name "*.png" \
-not -name "*.jpg" \
-not -name "*.jpeg" \
-not -name "*.ico" \
-not -name "*.pyc" \
-not -name ".DS_Store" \
-not -name "uv.lock" \
-not -name "poetry.lock" \
-not -name "package-lock.json" \
-not -name "project_export.txt" \
-print | while read -r filepath; do
    echo "Appending code file: ${filepath}"
    
    echo "" >> "$OUTPUT_FILE"
    echo "======================================================================" >> "$OUTPUT_FILE"
    echo "FILE: ${filepath}" >> "$OUTPUT_FILE"
    echo "======================================================================" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    cat "${filepath}" >> "$OUTPUT_FILE"
done