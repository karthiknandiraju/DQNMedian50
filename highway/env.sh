#!/usr/bin/env bash

RESULTS_DIR="/workspace/highway/results_highway_dqn_500_300_500"
VENV_DIR="/workspace/highway/highway_py37_env"
OUTFILE="${RESULTS_DIR}/experiment_environment.txt"

RUN_COMMAND='nohup python highway.py \
  --train-episodes 500 \
  --test-episodes 300 \
  --max-episode-steps 500 \
  --learning-rate 5e-5 \
  --epsilon 0.2 \
  --gamma 0.99 \
  --device cuda \
  --output-dir /workspace/highway/results_highway_dqn_500_300_500 \
  > /workspace/highway/highway_dqn_500_300_500.log 2>&1 &'

mkdir -p "$RESULTS_DIR"

if [ ! -f "$VENV_DIR/bin/activate" ]; then
    echo "Virtual environment not found: $VENV_DIR"
    exit 1
fi

source "$VENV_DIR/bin/activate"

PYTHON_BIN="$VENV_DIR/bin/python"
PIP_BIN="$VENV_DIR/bin/pip"

{
    echo "============================================================"
    echo "HIGHWAY DQN EXPERIMENT ENVIRONMENT"
    echo "============================================================"
    echo

    echo "Capture Time"
    echo "------------------------------------------------------------"
    date
    echo

    echo "Run Command"
    echo "------------------------------------------------------------"
    echo "$RUN_COMMAND"
    echo

    echo "Virtual Environment"
    echo "------------------------------------------------------------"
    echo "Name: highway_py37_env"
    echo "Path: $VENV_DIR"
    echo

    echo "Python"
    echo "------------------------------------------------------------"
    echo "Executable: $PYTHON_BIN"
    "$PYTHON_BIN" --version 2>&1
    echo

    echo "Pip"
    echo "------------------------------------------------------------"
    echo "Executable: $PIP_BIN"
    "$PIP_BIN" --version 2>&1
    echo

    echo "Installed Packages"
    echo "------------------------------------------------------------"
    "$PYTHON_BIN" -m pip freeze
    echo

    echo "Operating System"
    echo "------------------------------------------------------------"
    uname -a
    [ -f /etc/os-release ] && cat /etc/os-release
    echo

    echo "CPU"
    echo "------------------------------------------------------------"
    lscpu 2>/dev/null || true
    echo

    echo "Memory"
    echo "------------------------------------------------------------"
    free -h 2>/dev/null || true
    echo

    echo "GPU"
    echo "------------------------------------------------------------"
    nvidia-smi 2>/dev/null || echo "nvidia-smi unavailable"
    echo

    echo "CUDA"
    echo "------------------------------------------------------------"
    nvcc --version 2>/dev/null || echo "nvcc unavailable"
    echo

    echo "Working Directory"
    echo "------------------------------------------------------------"
    pwd
    echo

    echo "Git Information"
    echo "------------------------------------------------------------"
    git branch --show-current 2>/dev/null || true
    git rev-parse HEAD 2>/dev/null || true

} > "$OUTFILE"

echo "Environment successfully captured."
echo "Output file:"
echo "$OUTFILE"
